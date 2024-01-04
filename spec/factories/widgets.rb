FactoryBot.define do
  factory :widget do
    user
    sequence(:name) { |n| "#{Faker::Appliance.equipment} #{n}" }
    multiplier { Faker::Number.number }
  end
end
