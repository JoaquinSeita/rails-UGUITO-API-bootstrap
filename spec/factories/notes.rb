FactoryBot.define do
  factory :note do
    user
    sequence(:title) { |n| "#{Faker::Lorem.lines}#{n}" }
    content { Faker::Lorem.paragraph }
    note_type { TYPES_ATTRIBUTES.sample }
  end
end
