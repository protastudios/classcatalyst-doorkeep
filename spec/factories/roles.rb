FactoryBot.define do
  factory :role do
    user { nil }
    role_type_id { 1 }
    roleable { nil }
  end
end
