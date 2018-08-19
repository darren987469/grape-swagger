# frozen_string_literal: true

module GrapeSwagger
  module DocMethods
    class PathString
      class << self
        def path(route, options = {})
          path = format_path(route)

          if route.version && options[:add_version]
            version = GrapeSwagger::DocMethods::Version.get(route)
            version = version.first while version.is_a?(Array)
            path.sub!('{version}', version.to_s)
          else
            path.sub!('/{version}', '')
          end

          path = "#{OptionalObject.build(:base_path, options)}#{path}" if options[:add_base_path]

          path.start_with?('/') ? path : "/#{path}"
        end

        # item from path, this could be used for the schema object
        def item(route)
          path = format_path(route)
          path_name = path.gsub(%r{/{(.+?)}}, '').split('/').last
          path_name.present? ? path_name.singularize.underscore.camelize : 'Item'
        end

        private

        def format_path(route)
          path = route.path.dup
          # always removing format
          path.sub!(/\(\.\w+?\)$/, '')
          path.sub!('(.:format)', '')

          # ... format path params
          path.gsub!(/:(\w+)/, '{\1}')

          path
        end
      end
    end
  end
end
