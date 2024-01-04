require 'rails_helper'

RSpec.describe V1::TranslationsController do
  let(:not_found_error) do
    {
      status: 'error',
      error: 'Record Not Found',
      error_messages: ['Record Not Found']
    }.stringify_keys
  end

  describe '#get' do
    before do
      create(:translation, locale: 'en', key: 'foo', value: 'barbar')
    end

    it 'returns a valid translation' do
      get :show, params: { locale: 'en', key: 'foo' }, format: 'json'
      expect(payload).to eq('value' => 'barbar')
    end

    it 'does not return a translation in the wrong locale' do
      get :show, params: { locale: 'ru', key: 'foo' }, format: 'json'
      expect(payload).to eq(not_found_error)
    end

    it 'does not return an invalid translation' do
      get :show, params: { locale: 'en', key: 'bar' }, format: 'json'
      expect(payload).to eq(not_found_error)
    end
  end
end
