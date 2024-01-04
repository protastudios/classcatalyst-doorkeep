FactoryBot.define do
  factory :translation do
    locale { 'en' }
    key { Faker::Hipster.words(3).join('.') }
    value { Faker::Hipster.sentence }
    interpolations { nil }
    is_proc { false }
  end
end
