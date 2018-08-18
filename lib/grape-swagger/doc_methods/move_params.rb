# frozen_string_literal: true

require 'active_support/core_ext/hash/deep_merge'

module GrapeSwagger
  module DocMethods
    class MoveParams
      class << self
        attr_accessor :schemas

        def can_be_moved?(params, http_verb)
          move_methods.include?(http_verb) && includes_body_param?(params)
        end

        def to_schema(path, params, route, components)
          @schemas = components[:schemas]
          unify!(params)

          params_to_move = movable_params(params)

          return (params + correct_array_param(params_to_move)) if should_correct_array?(params_to_move)

          params << parent_schema_of_params(params_to_move, path, route)

          params
        end

        private

        def should_correct_array?(param)
          param.length == 1 && param.first[:in] == 'body' && param.first[:type] == 'array'
        end

        def correct_array_param(param)
          param.first[:schema] = { type: param.first.delete(:type), items: param.first.delete(:items) }

          param
        end

        def parent_schema_of_params(params, path, route)
          schema_name = OperationId.manipulate(parse_model(path))
          referenced_schema = build_schema(schema_name, params, route.request_method.downcase)
          schema = @schemas[referenced_schema]

          move_params_to_new(schema, params)

          schema[:description] = route.description if route.try(:description)

          build_body_parameter(referenced_schema, schema_name, route.options)
        end

        def move_params_to_new(schema, params)
          params, nested_params = params.partition { |x| !x[:name].to_s.include?('[') }

          unless params.blank?
            properties, required = build_properties(params)
            add_properties_to_schema(schema, properties, required)
          end

          nested_properties = build_nested_properties(nested_params) unless nested_params.blank?
          add_properties_to_schema(schema, nested_properties, []) unless nested_params.blank?
        end

        def build_properties(params)
          properties = {}
          required = []

          prepare_nested_types(params) if should_expose_as_array?(params)

          params.each do |param|
            name = param[:name].to_sym

            properties[name] = if should_expose_as_array?([param])
                                 document_as_array(param)
                               else
                                 document_as_property(param)
                               end

            required << name if deletable?(param) && param[:required]
          end

          [properties, required]
        end

        def document_as_array(param)
          {}.tap do |property|
            property[:type] = 'array'
            property[:description] = param.delete(:description) unless param[:description].nil?
            property[:items] = document_as_property(param)[:items]
          end
        end

        def document_as_property(param)
          property_keys.each_with_object({}) do |x, memo|
            value = param[x]
            next if value.blank?
            if x == :type && @schemas[value].present?
              memo['$ref'] = "#/components/schemas/#{value}"
            else
              memo[x] = value
            end
          end
        end

        def build_nested_properties(params, properties = {})
          property = params.bsearch { |x| x[:name].include?('[') }[:name].split('[').first

          nested_params, params = params.partition { |x| x[:name].start_with?("#{property}[") }
          prepare_nested_names(property, nested_params)

          recursive_call(properties, property, nested_params) unless nested_params.empty?
          build_nested_properties(params, properties) unless params.empty?

          properties
        end

        def recursive_call(properties, property, nested_params)
          if should_expose_as_array?(nested_params)
            properties[property.to_sym] = array_type
            move_params_to_new(properties[property.to_sym][:items], nested_params)
          else
            properties[property.to_sym] = object_type
            move_params_to_new(properties[property.to_sym], nested_params)
          end
        end

        def movable_params(params)
          to_delete = params.each_with_object([]) { |x, memo| memo << x if deletable?(x) }
          delete_from(params, to_delete)

          to_delete
        end

        def delete_from(params, to_delete)
          to_delete.each { |x| params.delete(x) }
        end

        def add_properties_to_schema(schema, properties, required)
          if schema.key?(:items)
            schema[:items][:properties].deep_merge!(properties)
            add_to_required(schema[:items], required)
          else
            schema[:properties].deep_merge!(properties)
            add_to_required(schema, required)
          end
        end

        def add_to_required(schema, value)
          return if value.blank?

          schema[:required] ||= []
          schema[:required].push(*value)
        end

        def build_body_parameter(reference, name, options)
          {}.tap do |x|
            x[:name] = options[:body_name] || name
            x[:in] = 'body'
            x[:required] = true
            x[:schema] = { '$ref' => "#/components/schemas/#{reference}" }
          end
        end

        def build_schema(name, params, verb = nil)
          name = "#{verb}#{name}" if verb
          @schemas[name] = should_expose_as_array?(params) ? array_type : object_type

          name
        end

        def array_type
          { type: 'array', items: { type: 'object', properties: {} } }
        end

        def object_type
          { type: 'object', properties: {} }
        end

        def prepare_nested_types(params)
          params.each do |param|
            next unless param[:items]

            param[:type] = if param[:items][:type] == 'array'
                             'string'
                           elsif param[:items].key?('$ref')
                             param[:type] = 'object'
                           else
                             param[:items][:type]
                           end
            param[:format] = param[:items][:format] if param[:items][:format]
            param.delete(:items) if param[:type] != 'object'
          end
        end

        def prepare_nested_names(property, params)
          params.each { |x| x[:name] = x[:name].sub(property, '').sub('[', '').sub(']', '') }
        end

        def unify!(params)
          params.each { |x| x[:in] = x.delete(:param_type) if x[:param_type] }
          params.each { |x| x[:in] = 'body' if x[:in] == 'formData' } if includes_body_param?(params)
        end

        def parse_model(ref)
          parts = ref.split('/')
          parts.last.include?('{') ? parts[0..-2].join('/') : parts[0..-1].join('/')
        end

        def property_keys
          %i[type format description minimum maximum items enum]
        end

        def deletable?(param)
          param[:in] == 'body'
        end

        def move_methods
          [:post, :put, :patch, 'POST', 'PUT', 'PATCH']
        end

        def includes_body_param?(params)
          params.map { |x| return true if x[:in] == 'body' || x[:param_type] == 'body' }
          false
        end

        def should_expose_as_array?(params)
          should_exposed_as(params) == 'array'
        end

        def should_exposed_as(params)
          params.map { |x| return 'object' if x[:type] && x[:type] != 'array' }
          'array'
        end
      end
    end
  end
end
