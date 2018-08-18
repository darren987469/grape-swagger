# frozen_string_literal: true

require 'spec_helper'

describe Grape::Endpoint do
  let(:endpoint) { described_class.new(Grape::Util::InheritableSetting.new, path: '/', method: :get) }

  context 'info object' do
    let(:infos) do
      {
        title: 'title',
        description: 'description',
        terms_of_service_url: 'terms_of_service_url',
        version: 'version',
        license: 'license',
        license_url: 'license_url',
        contact_name: 'contact_name',
        contact_email: 'contact_email',
        contact_url: 'contact_url'
      }
    end

    describe '#info_object' do
      subject { endpoint.send(:info_object, infos) }

      it { expect(subject[:title]).to eq infos[:title] }
      it { expect(subject[:description]).to eq infos[:description] }
      it { expect(subject[:termsOfService]).to eq infos[:terms_of_service_url] }
      it { expect(subject[:contact]).to eq endpoint.send(:contact_object, infos) }
      it { expect(subject[:license]).to eq endpoint.send(:license_object, infos) }
      it { expect(subject[:version]).to eq infos[:version] }
    end

    describe '#license_object' do
      subject { endpoint.send(:license_object, infos) }

      it { expect(subject[:name]).to eq infos[:license] }
      it { expect(subject[:url]).to eq infos[:license_url] }
    end

    describe '#contact_object' do
      subject { endpoint.send(:contact_object, infos) }

      it { expect(subject[:name]).to eq infos[:contact_name] }
      it { expect(subject[:email]).to eq infos[:contact_email] }
      it { expect(subject[:url]).to eq infos[:contact_url] }
    end
  end

  describe '#param_type_is_array?' do
    subject { described_class.new(Grape::Util::InheritableSetting.new, path: '/', method: :get) }

    it 'returns true if the value passed represents an array' do
      expect(subject.send(:param_type_is_array?, 'Array')).to be_truthy
      expect(subject.send(:param_type_is_array?, '[String]')).to be_truthy
      expect(subject.send(:param_type_is_array?, 'Array[Integer]')).to be_truthy
    end

    it 'returns false if the value passed does not represent an array' do
      expect(subject.send(:param_type_is_array?, 'String')).to be_falsey
      expect(subject.send(:param_type_is_array?, '[String, Integer]')).to be_falsey
    end
  end

  describe 'parse_request_params' do
    subject { described_class.new(Grape::Util::InheritableSetting.new, path: '/', method: :get) }
    before do
      subject.send(:parse_request_params, params)
    end

    context 'when params do not contain an array' do
      let(:params) do
        [
          ['id', { required: true, type: 'String' }],
          ['description', { required: false, type: 'String' }]
        ]
      end

      let(:expected_params) do
        [
          ['id', { required: true, type: 'String' }],
          ['description', { required: false, type: 'String' }]
        ]
      end

      it 'parses params correctly' do
        expect(params).to eq expected_params
      end
    end

    context 'when params contain a simple array' do
      let(:params) do
        [
          ['id', { required: true, type: 'String' }],
          ['description', { required: false, type: 'String' }],
          ['stuffs', { required: true, type: 'Array[String]' }]
        ]
      end

      let(:expected_params) do
        [
          ['id', { required: true, type: 'String' }],
          ['description', { required: false, type: 'String' }],
          ['stuffs', { required: true, type: 'Array[String]', is_array: true }]
        ]
      end

      it 'parses params correctly and adds is_array to the array' do
        expect(params).to eq expected_params
      end
    end

    context 'when params contain a complex array' do
      let(:params) do
        [
          ['id', { required: true, type: 'String' }],
          ['description', { required: false, type: 'String' }],
          ['stuffs', { required: true, type: 'Array' }],
          ['stuffs[id]', { required: true, type: 'String' }]
        ]
      end

      let(:expected_params) do
        [
          ['id', { required: true, type: 'String' }],
          ['description', { required: false, type: 'String' }],
          ['stuffs', { required: true, type: 'Array', is_array: true }],
          ['stuffs[id]', { required: true, type: 'String', is_array: true }]
        ]
      end

      it 'parses params correctly and adds is_array to the array and all elements' do
        expect(params).to eq expected_params
      end

      context 'when array params are not contiguous with parent array' do
        let(:params) do
          [
            ['id', { required: true, type: 'String' }],
            ['description', { required: false, type: 'String' }],
            ['stuffs', { required: true, type: 'Array' }],
            ['stuffs[owners]', { required: true, type: 'Array' }],
            ['stuffs[creators]', { required: true, type: 'Array' }],
            ['stuffs[owners][id]', { required: true, type: 'String' }],
            ['stuffs[creators][id]', { required: true, type: 'String' }],
            ['stuffs_and_things', { required: true, type: 'String' }]
          ]
        end

        let(:expected_params) do
          [
            ['id', { required: true, type: 'String' }],
            ['description', { required: false, type: 'String' }],
            ['stuffs', { required: true, type: 'Array', is_array: true }],
            ['stuffs[owners]', { required: true, type: 'Array', is_array: true }],
            ['stuffs[creators]', { required: true, type: 'Array', is_array: true }],
            ['stuffs[owners][id]', { required: true, type: 'String', is_array: true }],
            ['stuffs[creators][id]', { required: true, type: 'String', is_array: true }],
            ['stuffs_and_things', { required: true, type: 'String' }]
          ]
        end

        it 'parses params correctly and adds is_array to the array and all elements' do
          expect(params).to eq expected_params
        end
      end
    end
  end
end