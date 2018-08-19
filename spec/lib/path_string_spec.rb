# frozen_string_literal: true

require 'spec_helper'

describe GrapeSwagger::DocMethods::PathString do
  subject { described_class }

  specify { expect(subject).to eql GrapeSwagger::DocMethods::PathString }
  specify { expect(subject).to respond_to :path }
  specify { expect(subject).to respond_to :item }

  describe 'path_string_object' do
    specify 'The original route path is not mutated' do
      route = Struct.new(:version, :path).new
      route.path = '/foo/:dynamic/bar'
      subject.path(route, add_version: true)
      expect(route.path).to eq '/foo/:dynamic/bar'
    end

    describe 'version' do
      describe 'defaults: given, true' do
        let(:options) { { add_version: true } }
        let(:route) { Struct.new(:version, :path).new('v1') }

        specify 'The returned path includes version' do
          route.path = '/{version}/thing(.json)'
          expect(subject.path(route, options)).to eql '/v1/thing'
          expect(subject.item(route)).to eql 'Thing'

          route.path = '/{version}/thing/foo(.json)'
          expect(subject.path(route, options)).to eql '/v1/thing/foo'
          expect(subject.item(route)).to eql 'Foo'

          route.path = '/{version}/thing(.:format)'
          expect(subject.path(route, options)).to eql '/v1/thing'
          expect(subject.item(route)).to eql 'Thing'

          route.path = '/{version}/thing/foo(.:format)'
          expect(subject.path(route, options)).to eql '/v1/thing/foo'
          expect(subject.item(route)).to eql 'Foo'

          route.path = '/{version}/thing/:id'
          expect(subject.path(route, options)).to eql '/v1/thing/{id}'
          expect(subject.item(route)).to eql 'Thing'

          route.path = '/{version}/thing/foo/:id'
          expect(subject.path(route, options)).to eql '/v1/thing/foo/{id}'
          expect(subject.item(route)).to eql 'Foo'
        end
      end

      describe 'defaults: not given, both false' do
        let(:options) { { add_version: false } }
        let(:route) { Struct.new(:version, :path).new }

        specify 'The returned path does not include version' do
          route.path = '/{version}/thing(.json)'
          expect(subject.path(route, options)).to eql '/thing'
          expect(subject.item(route)).to eql 'Thing'

          route.path = '/{version}/thing/foo(.json)'
          expect(subject.path(route, options)).to eql '/thing/foo'
          expect(subject.item(route)).to eql 'Foo'

          route.path = '/{version}/thing(.:format)'
          expect(subject.path(route, options)).to eql '/thing'
          expect(subject.item(route)).to eql 'Thing'

          route.path = '/{version}/thing/foo(.:format)'
          expect(subject.path(route, options)).to eql '/thing/foo'
          expect(subject.item(route)).to eql 'Foo'

          route.path = '/{version}/thing/:id'
          expect(subject.path(route, options)).to eql '/thing/{id}'
          expect(subject.item(route)).to eql 'Thing'

          route.path = '/{version}/thing/foo/:id'
          expect(subject.path(route, options)).to eql '/thing/foo/{id}'
          expect(subject.item(route)).to eql 'Foo'
        end
      end

      describe 'defaults: add_version false' do
        let(:options) { { add_version: false } }
        let(:route) { Struct.new(:version, :path).new('v1') }

        specify 'The returned path does not include version' do
          route.path = '/{version}/thing(.json)'
          expect(subject.path(route, options)).to eql '/thing'
          expect(subject.item(route)).to eql 'Thing'

          route.path = '/{version}/thing/foo(.json)'
          expect(subject.path(route, options)).to eql '/thing/foo'
          expect(subject.item(route)).to eql 'Foo'

          route.path = '/{version}/thing(.:format)'
          expect(subject.path(route, options)).to eql '/thing'
          expect(subject.item(route)).to eql 'Thing'

          route.path = '/{version}/thing/foo(.:format)'
          expect(subject.path(route, options)).to eql '/thing/foo'
          expect(subject.item(route)).to eql 'Foo'

          route.path = '/{version}/thing/:id'
          expect(subject.path(route, options)).to eql '/thing/{id}'
          expect(subject.item(route)).to eql 'Thing'

          route.path = '/{version}/thing/foo/:id'
          expect(subject.path(route, options)).to eql '/thing/foo/{id}'
          expect(subject.item(route)).to eql 'Foo'
        end
      end

      describe 'defaults: root_version nil' do
        let(:options) { { add_version: true } }
        let(:route) { Struct.new(:version, :path).new }

        specify 'The returned path does not include version' do
          route.path = '/{version}/thing(.json)'
          expect(subject.path(route, options)).to eql '/thing'
          expect(subject.item(route)).to eql 'Thing'

          route.path = '/{version}/thing/foo(.json)'
          expect(subject.path(route, options)).to eql '/thing/foo'
          expect(subject.item(route)).to eql 'Foo'

          route.path = '/{version}/thing(.:format)'
          expect(subject.path(route, options)).to eql '/thing'
          expect(subject.item(route)).to eql 'Thing'

          route.path = '/{version}/thing/foo(.:format)'
          expect(subject.path(route, options)).to eql '/thing/foo'
          expect(subject.item(route)).to eql 'Foo'

          route.path = '/{version}/thing/:id'
          expect(subject.path(route, options)).to eql '/thing/{id}'
          expect(subject.item(route)).to eql 'Thing'

          route.path = '/{version}/thing/foo/:id'
          expect(subject.path(route, options)).to eql '/thing/foo/{id}'
          expect(subject.item(route)).to eql 'Foo'
        end
      end
    end
  end
end
