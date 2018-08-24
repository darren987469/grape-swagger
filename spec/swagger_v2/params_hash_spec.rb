# frozen_string_literal: true

require 'spec_helper'

describe 'Group Params as Hash' do
  def app
    Class.new(Grape::API) do
      format :json

      params do
        requires :required_group, type: Hash do
          requires :required_param_1
          requires :required_param_2
        end
      end
      post '/use_groups' do
        { 'declared_params' => declared(params) }
      end

      params do
        requires :typed_group, type: Hash do
          requires :id, type: Integer, desc: 'integer given'
          requires :name, type: String, desc: 'string given'
          optional :email, type: String, desc: 'email given'
          optional :others, type: Integer, values: [1, 2, 3]
        end
      end
      post '/use_given_type' do
        { 'declared_params' => declared(params) }
      end

      add_swagger_documentation
    end
  end

  describe 'grouped parameters' do
    subject do
      get '/swagger_doc/use_groups'
      JSON.parse(last_response.body)
    end

    specify do
      expect(subject['paths']['/use_groups']['post']).to include('requestBody')
      expect(subject['paths']['/use_groups']['post']['requestBody']).to eql(
        'content' => {
          'application/json' => {
            'schema' => {
              'type' => 'object',
              'required' => ['required_group'],
              'properties' => {
                'required_group' => {
                  'type' => 'object',
                  'required' => %w[required_param_1 required_param_2],
                  'properties' => {
                    'required_param_1' => { 'type' => 'string' },
                    'required_param_2' => { 'type' => 'string' }
                  }
                }
              }
            }
          }
        }
      )
    end
  end

  describe 'grouped parameters with given type' do
    subject do
      get '/swagger_doc/use_given_type'
      JSON.parse(last_response.body)
    end

    specify do
      expect(subject['paths']['/use_given_type']['post']).to include('requestBody')
      expect(subject['paths']['/use_given_type']['post']['requestBody']).to eql(
        'content' => {
          'application/json' => {
            'schema' => {
              'type' => 'object',
              'required' => ['typed_group'],
              'properties' => {
                'typed_group' => {
                  'type' => 'object',
                  'required' => %w[id name],
                  'properties' => {
                    'id' => { 'type' => 'integer', 'description' => 'integer given' },
                    'name' => { 'type' => 'string', 'description' => 'string given' },
                    'email' => { 'type' => 'string', 'description' => 'email given' },
                    'others' => { 'type' => 'integer', enum: [1,2,3] }
                  }
                }
              }
            }
          }
        }
      )
    end
  end
end
