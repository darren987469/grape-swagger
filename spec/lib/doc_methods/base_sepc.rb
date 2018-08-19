# frozen_string_literal: true

require 'spec_helper'

describe GrapeSwagger::DocMethods::Base do
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

    subject { described_class.new(nil, nil, nil) }

    describe '#info_object' do
      subject { subject.send(:info_object, infos) }

      it { expect(subject[:title]).to eq infos[:title] }
      it { expect(subject[:description]).to eq infos[:description] }
      it { expect(subject[:termsOfService]).to eq infos[:terms_of_service_url] }
      it { expect(subject[:contact]).to eq subject.send(:contact_object, infos) }
      it { expect(subject[:license]).to eq subject.send(:license_object, infos) }
      it { expect(subject[:version]).to eq infos[:version] }
    end

    describe '#license_object' do
      subject { subject.send(:license_object, infos) }

      it { expect(subject[:name]).to eq infos[:license] }
      it { expect(subject[:url]).to eq infos[:license_url] }
    end

    describe '#contact_object' do
      subject { subject.send(:contact_object, infos) }

      it { expect(subject[:name]).to eq infos[:contact_name] }
      it { expect(subject[:email]).to eq infos[:contact_email] }
      it { expect(subject[:url]).to eq infos[:contact_url] }
    end
  end
end
