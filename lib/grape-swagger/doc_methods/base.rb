# frozen_string_literal: true

module GrapeSwagger
  module DocMethods
    class Base
      attr_reader :target_class, :request, :options

      # @param target_class [Class] API Class (which extend Grape::API)
      # @param request [Hash] Request of endpoint of API
      # @param options [Hash] Options of add_swagger_documentation
      def initialize(target_class, request, options)
        @target_class = target_class
        @request = request
        @options = options
      end

      def swagger_object
        object = {
          openapi:             '3.0.1',
          info:                info_object(options[:info].merge(version: options[:doc_version])),
          authorizations:      options[:authorizations],
          securityDefinitions: options[:security_definitions],
          security:            options[:security],
          host:                GrapeSwagger::DocMethods::OptionalObject.build(:host, options, request),
          basePath:            GrapeSwagger::DocMethods::OptionalObject.build(:base_path, options, request),
          schemes:             options[:schemes].is_a?(String) ? [options[:schemes]] : options[:schemes]
        }

        GrapeSwagger::DocMethods::Extensions.add_extensions_to_root(options, object)
        object.delete_if { |_, value| value.blank? }
      end

      private

      def info_object(infos)
        result = {
          title:          infos[:title] || 'API title',
          description:    infos[:description],
          termsOfService: infos[:terms_of_service_url],
          contact:        contact_object(infos),
          license:        license_object(infos),
          version:        infos[:version]
        }

        GrapeSwagger::DocMethods::Extensions.add_extensions_to_info(infos, result)

        result.delete_if { |_, value| value.blank? }
      end

      def contact_object(infos)
        {
          name: infos[:contact_name],
          email: infos[:contact_email],
          url: infos[:contact_url]
        }.delete_if { |_, value| value.blank? }
      end

      def license_object(infos)
        {
          name: infos[:license],
          url:  infos[:license_url]
        }.delete_if { |_, value| value.blank? }
      end
    end
  end
end
