# frozen_string_literal: true

require 'spec_helper'

describe 'document hash and array' do
  include_context "#{MODEL_PARSER} swagger example"

  before :all do
    module TheApi
      class TestApi < Grape::API
        format :json

        documentation = ::Entities::DocumentedHashAndArrayModel.documentation if ::Entities::DocumentedHashAndArrayModel.respond_to?(:documentation)

        desc 'This returns something'
        namespace :arbitrary do
          params do
            requires :id, type: Integer
          end
          route_param :id do
            desc 'Timeless treasure'
            params do
              requires :body, using: documentation unless documentation.nil?
              requires :raw_hash, type: Hash, documentation: { param_type: 'body' } if documentation.nil?
              requires :raw_array, type: Array, documentation: { param_type: 'body' } if documentation.nil?
            end
            put '/id_and_hash' do
              {}
            end
          end
        end

        add_swagger_documentation
      end
    end
  end

  def app
    TheApi::TestApi
  end

  subject do
    get '/swagger_doc'
    binding.pry
    JSON.parse(last_response.body)['components']['schemas']
  end
  describe 'generated request definition' do
    it 'has hash' do
      expect(subject.keys).to include('putArbitraryIdIdAndHash')
      expect(subject['putArbitraryIdIdAndHash']['properties'].keys).to include('raw_hash')
    end

    it 'has array' do
      expect(subject.keys).to include('putArbitraryIdIdAndHash')
      expect(subject['putArbitraryIdIdAndHash']['properties'].keys).to include('raw_array')
    end

    it 'does not have the path parameter' do
      expect(subject.keys).to include('putArbitraryIdIdAndHash')
      expect(subject['putArbitraryIdIdAndHash']).to_not include('id')
    end
  end
end
