module OpenApiParser
  # Responsible for interpreting a $ref value and
  # resolving it to a raw specification given a base URI.
  class Reference
    # The resolved document. This gets set only after calling `#resolve`.
    attr_reader :referrent_document

    # Pointer of the referrent_document if it's embedded in a larger document.
    # This gets set only after calling `#resolve`.
    # Empty string means the whole document.
    attr_reader :referrent_pointer

    def initialize(raw_uri)
      @raw_uri = raw_uri
      @resolved = false
    end

    # Sets referrent_document and referrent_pointer to the resolved
    # raw specification and pointer, respectively.
    #
    # @return [Boolean] Whether the referrent has been fully expanded.
    def resolve(base_path, base_pointer, current_document, file_cache)
      if @resolved
        fail 'Do not try to resolve an already resolved reference.'
      end
      @resolved = true

      ref_uri = Addressable::URI.parse(@raw_uri)

      fully_expanded, referenced_document, base_pointer =
        case ref_uri.scheme
        when nil, 'file'
          if ref_uri.path.empty?
            [false, current_document, base_pointer]
          else
            [true, resolve_file(ref_uri.path, base_path, file_cache), '']
          end
        else
          fail "$ref with scheme #{ref_uri.scheme} is not supported"
        end

      fully_expanded, @referrent_document, @referrent_pointer =
        if !ref_uri.fragment.nil? && ref_uri.fragment != ''
          resolve_pointer(ref_uri.fragment, base_pointer, referenced_document, fully_expanded)
        else
          [fully_expanded, referenced_document, '']
        end

      fully_expanded
    end

    private

    # @return [Hash] Resolved raw document
    def resolve_file(path, base_path, file_cache)
      absolute_path = File.expand_path(File.join("..", path), base_path)

      OpenApiParser::Document.resolve(absolute_path, file_cache)
    end

    # @param raw_pointer [String] Pointer to resolve.
    # @param base_pointer [String] The location of the $ref being resolved.
    #   This is empty if `within_document` is not the document where $ref is located.
    # @param within_document [Hash] Document in which to evaluate the pointer.
    # @return [Array<Boolean, Hash, String>]
    #   Whether the referrent has been fully expanded, resolved document, and pointer.
    def resolve_pointer(raw_pointer, base_pointer, within_document, fully_expanded)
      pointer = OpenApiParser::Pointer.new(raw_pointer)

      if pointer.equal_or_ancestor_of?(base_pointer)
        # prevent infinite recursion
        referrent_document = { "$ref" => '#' + raw_pointer }
        # referrent_document is simply a new $ref object pointing
        # at the same fragment; pointer to the document stays the same,
        # i.e. base_pointer.
        [true, referrent_document, base_pointer]
      else
        referrent_document = pointer.resolve(within_document)
        referrent_pointer = base_pointer + pointer.escaped_pointer
        [fully_expanded, referrent_document, referrent_pointer]
      end
    end
  end
end
