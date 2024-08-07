FactoryBot.define do
  factory :utility do
    initialize_with do
      klass = type.constantize
      klass.new(attributes)
    end

    # Adds a number to the name to avoid duplicates and fail because of the uniqueness
    sequence(:name) { |n| "#{Faker::Lorem.word}#{n}" }
    type { Utility.subclasses.map(&:to_s).sample }
    short_threshold { Faker::Number.between(from: 50, to: 100) }
    medium_threshold { Faker::Number.between(from: short_threshold + 1, to: 200) }
  end
end
