FactoryBot.define do
  factory :global_setting do
    name { Faker::ProgrammingLanguage.name }
    value do
      {
        flavor: Faker::Coffee.notes.split(', '),
        creator: Faker::ProgrammingLanguage.creator
      }
    end
  end
end
