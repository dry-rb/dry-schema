# frozen_string_literal: true

require 'dry/schema/result'

RSpec.describe Dry::Schema::Result, '#error?' do
  subject(:result) { schema.(input) }

  context 'with a flat structure' do
    let(:schema) do
      Dry::Schema.Params { required(:name).filled }
    end

    context 'when there is no error' do
      let(:input) do
        { name: 'test' }
      end

      it 'returns false' do
        expect(result.error?(:name)).to be(false)
      end
    end

    context 'when there is an error' do
      let(:input) do
        { name: '' }
      end

      it 'returns true' do
        expect(result.error?(:name)).to be(true)
      end
    end
  end

  context 'with a nested hash' do
    let(:schema) do
      Dry::Schema.Params do
        required(:user).hash do
          required(:address).hash do
            required(:street).filled
          end
        end
        optional(:address).filled(:string)
      end
    end

    context 'when there is no error' do
      let(:input) do
        { user: { address: { street: 'test' } } }
      end

      it 'returns false for a hash spec' do
        expect(result.error?(user: { address: :street })).to be(false)
      end

      it 'returns false for dot notation spec' do
        expect(result.error?('user.address.street')).to be(false)
      end
    end

    context 'when there is an error under matching key but in another branch' do
      let(:input) do
        { user: { address: { street: 'test' } }, address: '' }
      end

      it 'returns false for a hash spec' do
        expect(result.error?(user: { address: :street })).to be(false)
      end

      it 'returns false for dot notation spec' do
        expect(result.error?('user.address.street')).to be(false)
      end
    end

    context 'when there is an error under the last key' do
      let(:input) do
        { user: { address: { street: '' } } }
      end

      it 'returns true for a hash spec' do
        expect(result.error?(user: { address: :street })).to be(true)
      end

      it 'returns true for dot notation spec' do
        expect(result.error?('user.address.street')).to be(true)
      end
    end

    context 'when there is an error under one of the intermediate keys' do
      let(:input) do
        { user: { address: nil } }
      end

      it 'returns true for a hash spec' do
        expect(result.error?(user: { address: :street })).to be(true)
      end

      it 'returns true for dot notation spec' do
        expect(result.error?('user.address.street')).to be(true)
      end
    end
  end
end
