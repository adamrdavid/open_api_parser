# frozen_string_literal: true

module OpenApiParser
  module Specification
    META_SCHEMA_PATH_2 = File.expand_path('../../resources/swagger_meta_schema_2.0.json', __dir__)
    META_SCHEMA_PATH_3 = File.expand_path('../../resources/swagger_meta_schema_3.0.json', __dir__)

    def self.resolve(path, validate_meta_schema: true)
      raw_specification = Document.resolve(path)

      if validate_meta_schema
        meta_schema = JSON.parse(File.read(meta_schema_path(raw_specification)))
        JSON::Validator.validate!(meta_schema, raw_specification)
      end

      OpenApiParser::Specification::Root.new(raw_specification)
    end

    def self.meta_schema_path(raw_specification)
      if raw_specification.key?('openapi')
        META_SCHEMA_PATH_3
      else
        META_SCHEMA_PATH_2
      end
    end
  end
end
