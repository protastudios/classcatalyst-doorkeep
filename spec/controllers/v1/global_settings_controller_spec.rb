require 'rails_helper'

RSpec.describe V1::GlobalSettingsController do
  describe '#get' do
    let(:my_config) do
      {
        flavor: 'chocolate',
        temp: 32,
        fizz: { buzz: 3 }
      }.as_json
    end

    before do
      my_config.each do |k, v|
        create(:global_setting, name: k, value: v)
      end
      Rails.cache.delete('global_settings') # Ensure we don't serve a cached copy
    end

    it 'returns the global settings' do
      get :index, format: 'json'
      expect(payload).to eq(my_config)
    end
  end
end
