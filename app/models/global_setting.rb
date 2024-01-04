class GlobalSetting < ApplicationRecord
  validates :name, presence: true, uniqueness: { case_sensitive: false }

  def value_json
    value.present? ? JSON.dump(value) : ''
  end

  def value_json=(json)
    self.value = json.present? ? JSON.parse("[#{json}]").first : nil
  end
end
