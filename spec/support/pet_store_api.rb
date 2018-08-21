# frozen_string_literal: true

RSpec.shared_context 'pet store api' do
  before(:all) do
    class PetStoreApi < Grape::API
      module Entities
        class Pet < Grape::Entity
          expose :id, documentation: { type: Integer, required: true }
          expose :name, documentation: { type: String, required: true }
          expose :tag, documentation: { type: String }
        end

        class Error < Grape::Entity
          expose :code, documentation: { type: Integer, required: true }
          expose :message, documentation: { type: String, required: true }
        end
      end

      resources :pets do
        desc 'List all pets',
             is_array: true,
             success: {
               message: 'A paged array of pets',
               model: Entities::Pet,
               headers: {
                'x-next' => {
                  description: 'A link to the next page of responses',
                  schema: { type: 'string' }
                }
               }
             }
        params do
          optional :limit, type: Integer, desc: 'How many items to return at one time (max 100)'
        end
        get do
          present [], with: Entities::Pet
        end

        desc 'Create a pet',
             success: { message: 'Null response' }
        post do
          @body = nil
        end

        desc 'Info for a specific pet',
             success: { message: 'Expected response to a valid request', model: Entities::Pet }
        params do
          requires :petId, type: String, desc: 'The id of the pet to retrieve'
        end
        get ':id' do
          present OpenStruct.new(id: 1, name: 'dog', tag: 'good dog'), with: Entities::Pet
        end
      end

      add_swagger_documentation \
        doc_version: '1.0.0',
        info: {
          title: 'Swagger Petstore',
          license: 'MIT'
        },
        servers: [{ url: 'http://petstore.swagger.io/v1' }],
        models: [
          Entities::Error,
          Entities::Pet
        ]
    end
  end

  def app
    PetStoreApi
  end

  # source can be found at https://github.com/OAI/OpenAPI-Specification/blob/master/examples/v3.0/petstore.yaml
  let(:expected) do
    {
      'openapi' => '3.0.1',
      'info' => {
        'version' => '1.0.0',
        'title' => 'Swagger Petstore',
        'license' => { 'name' => 'MIT' }
      },
      # Not support yet
      # "servers" => [{ "url" => "http://petstore.swagger.io/v1" }],
      'paths' => {
        '/pets' => {
          'get' => {
            'summary' => 'List all pets',
            'operationId' => 'getPets',
            'tags' => ['pets'],
            'parameters' => [{
              'name' => 'limit',
              'in' => 'query',
              'description' => 'How many items to return at one time (max 100)',
              'required' => false,
              'schema' => {
                'type' => 'integer', 'format' => 'int32'
              }
            }],
            'responses' => {
              '200' => {
                'description' => 'A paged array of pets',
                'headers' => {
                  'x-next' => {
                    'description' => 'A link to the next page of responses',
                    'schema' => {
                      'type' => 'string'
                    }
                  }
                },
                'content' => {
                  'application/json' => {
                    'schema' => {
                      'type' => 'array',
                      'items' => { '$ref' => '#/components/schemas/Pet' }
                    }
                  }
                }
              },
              # Not support
              # "default" => {
              #   "description" => "unexpected error",
              #   "content" => {
              #     "application/json" => {
              #       "schema" => {
              #         "$ref" => "#/components/schemas/Error"
              #       }
              #     }
              #   }
              # }
            }
          },
          'post' => {
            'summary' => 'Create a pet',
            'operationId' => 'postPets',
            'tags' => ['pets'],
            'responses' => {
              '201' => {
                'description' => 'Null response'
              },
              # Not support yet
              # "default" => {
              #   "description" => "unexpected error",
              #   "content" => {
              #     "application/json" => {
              #       "schema" => {
              #         "$ref" => "#/components/schemas/Error"
              #       }
              #     }
              #   }
              # }
            }
          }
        },
        '/pets/{id}' => {
          'get' => {
            'summary' => 'Info for a specific pet',
            'operationId' => 'getPetsId',
            'tags' => ['pets'],
            'parameters' => [{
              'name' => 'petId',
              'in' => 'path',
              'required' => true,
              'description' => 'The id of the pet to retrieve',
              'schema' => {
                'type' => 'string'
              }
            }],
            'responses' => {
              '200' => {
                'description' => 'Expected response to a valid request',
                'content' => {
                  'application/json' => {
                    'schema' => {
                      '$ref' => '#/components/schemas/Pets'
                    }
                  }
                }
              },
              # Not Support yet
              # "default" => {
              #   "description" => "unexpected error",
              #   "content" => {
              #     "application/json" => {
              #       "schema" => {
              #         "$ref" => "#/components/schemas/Error"
              #       }
              #     }
              #   }
              # }
            }
          }
        }
      },
      'components' => {
        'schemas' => {
          'Pet' => {
            'type' => 'object',
            'required' => %w[id name],
            'properties' => {
              'id' => {
                'type' => 'integer', 'format' => 'int32'
              },
              'name' => {
                'type' => 'string'
              },
              'tag' => {
                'type' => 'string'
              }
            }
          },
          # Not support yet
          # "Pets" => {
          #   "type" => "array",
          #   "items" => {
          #     "$ref" => "#/components/schemas/Pet"
          #   }
          # },
          'Error' => {
            'type' => 'object',
            'required' => %w[code message],
            'properties' => {
              'code' => {
                'type' => 'integer', 'format' => 'int32'
              },
              'message' => {
                'type' => 'string'
              }
            }
          }
        }
      }
    }
  end
end
