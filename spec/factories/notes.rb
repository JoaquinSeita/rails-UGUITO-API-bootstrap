FactoryBot.define do
  factory :note do
    user
    note_type { %w[review critique].sample }
    title { Faker::Book.title }
    content { Faker::Lorem.paragraph }
  end
end
