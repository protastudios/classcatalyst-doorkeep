require 'rails_helper'

RSpec.describe Translation, type: :model do
  describe 'with a valid entry' do
    let(:key) { 'foo.bar' }
    let(:text) { 'Yadda yadda' }

    before { create(:translation, key: key, value: text) }

    it 'hooks into I18n#t' do
      expect(I18n.t(key)).to eq(text)
    end
  end
end
