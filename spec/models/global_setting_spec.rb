require 'rails_helper'

RSpec.describe GlobalSetting, type: :model do
  subject(:setting) { create(:global_setting) }

  describe '#value_json' do
    it 'dumps the value as JSON' do
      expect(setting.value_json).to eq(setting.value.to_json)
    end
  end
end
