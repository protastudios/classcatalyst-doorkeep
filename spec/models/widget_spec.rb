require 'rails_helper'

RSpec.describe Widget, type: :model do
  describe 'factory instance' do
    it 'is valid' do
      expect(create(:widget)).to be_valid
    end
  end
end
