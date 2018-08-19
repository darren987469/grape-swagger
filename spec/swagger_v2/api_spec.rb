# frozen_string_literal: true

require 'spec_helper'

describe 'body parameter definitions' do
  include_context 'pet store api'

  subject do
    get '/swagger_doc'
    JSON.parse(last_response.body)
  end

  it { expect(subject['openapi']).to eq expected['openapi'] }
  it { expect(subject['info']).to eq expected['info'] }
  it { expect(subject['components']['schemas']['Pet']).to eq expected['components']['schemas']['Pet'] }
  it { expect(subject['components']['schemas']['Error']).to eq expected['components']['schemas']['Error'] }
end
