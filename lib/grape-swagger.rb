# frozen_string_literal: true

require 'grape'

require 'grape-swagger/version'
require 'grape-swagger/errors'
require 'grape-swagger/doc_methods'
require 'grape-swagger/model_parsers'

module GrapeSwagger
  class << self
    def model_parsers
      @model_parsers ||= GrapeSwagger::ModelParsers.new
    end
  end
  autoload :Rake, 'grape-swagger/rake/oapi_tasks'
end

require 'grape-swagger/grape/api'
require 'grape-swagger/grape/endpoint'
