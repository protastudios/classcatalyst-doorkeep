FactoryBot.define do
  factory :identity do
    user
    provider { 'linkedin' }
    sequence(:uid) { |n| "ProviderUID#{n}" }
    sequence(:token) { |n| "OAuthToken#{n}" }

    transient do
      sequence(:email) { |n| "Foo#{n}@test.com" }
      sequence(:name) { |n| "Charles #{n}" }
    end

    info { { email: email, name: name } }
    extra { {} }
  end
end
