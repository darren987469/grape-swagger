# frozen_string_literal: true

module GrapeSwagger
  module DocMethods
    class Extensions
      class << self
        def add(path, components, route)
          @route = route

          description = route.settings[:description]
          add_extension_to(path[method], extension(description)) if description && extended?(description, :x)

          settings = route.settings
          add_extensions_to_operation(settings, path, route) if settings && extended?(settings, :x_operation)
          add_extensions_to_path(settings, path) if settings && extended?(settings, :x_path)
          add_extensions_to_schema(settings, path, components[:schemas]) if settings && extended?(settings, :x_schema)
        end

        def add_extensions_to_root(settings, object)
          add_extension_to(object, extension(settings)) if extended?(settings, :x)
        end

        def add_extensions_to_info(settings, info)
          add_extension_to(info, extension(settings)) if extended?(settings, :x)
        end

        def add_extensions_to_operation(settings, path, route)
          add_extension_to(path[route.request_method.downcase.to_sym], extension(settings, :x_operation))
        end

        def add_extensions_to_path(settings, path)
          add_extension_to(path, extension(settings, :x_path))
        end

        def add_extensions_to_schema(settings, path, schemas)
          schema_extension = extension(settings, :x_schema)

          if schema_extension[:x_schema].is_a?(Array)
            schema_extension[:x_schema].each { |extension| setup_schema(extension, path, schemas) }
          else
            setup_schema(schema_extension[:x_schema], path, schemas)
          end
        end

        private

        def setup_schema(schema_extension, path, schemas)
          return unless schema_extension.key?(:for)
          status = schema_extension[:for]

          schema = find_schema(status, path)
          add_extension_to(schemas[schema], x_schema: schema_extension)
        end

        def find_schema(status, path)
          response = path[method][:responses][status]
          return if response.nil?

          return response[:schema]['$ref'].split('/').last if response[:schema].key?('$ref')
          return response[:schema]['items']['$ref'].split('/').last if response[:schema].key?('items')
        end

        def add_extension_to(part, extensions)
          return if part.nil?
          concatenate(extensions).each do |key, value|
            part[key] = value unless key.start_with?('x-for')
          end
        end

        def concatenate(extensions)
          result = {}

          extensions.each_value do |extension|
            extension.each do |key, value|
              result["x-#{key}"] = value
            end
          end

          result
        end

        def extended?(part, identifier = :x)
          !extension(part, identifier).empty?
        end

        def extension(part, identifier = :x)
          part.select { |x| x == identifier }
        end

        def method
          @route.request_method.downcase.to_sym
        end
      end
    end
  end
end
