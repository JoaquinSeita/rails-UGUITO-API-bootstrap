require 'rails_helper'

RSpec.describe Note, type: :model do
  subject(:note) do
    create(:note)
  end

  it { is_expected.to belong_to(:user) }
  it { is_expected.to have_one(:utility).through(:user) }
  it { is_expected.to define_enum_for(:note_type).with_values(%i[review critique]) }

  %i[user_id title content note_type].each do |value|
    it { is_expected.to validate_presence_of(value) }
  end

  it { is_expected.to be_valid }

  describe '#validate_content_word_count' do
    context 'when note type is review and content length is not short' do
      let(:user) { create(:user) }
      let(:word_count) { Faker::Number.between(from: user.utility.short_threshold + 1) }
      let(:note) do
        build(:note, user: user, note_type: :review, content: Faker::Lorem.sentence(word_count: word_count))
      end

      it 'adds an error to the content attribute' do
        note.valid?
        expect(note.errors).not_to be_empty
      end
    end

    context 'when note type is review and content length is short' do
      let(:note) { build(:note, note_type: :review, content: 'This is a short content') }

      it 'does not add an error to the content attribute' do
        note.valid?
        expect(note.errors).not_to be_empty
      end
    end
  end

  describe '#word_count' do
    let(:words_to_generate) { Faker::Number.between(from: 0, to: 1000) }
    let(:note) { build(:note, content: Faker::Lorem.sentence(word_count: words_to_generate)) }

    it 'returns the number of words in the content' do
      expect(note.word_count).to eq(words_to_generate)
    end
  end

  describe '#content_length' do
    let(:utility) { create(:utility) }
    let(:user) { create(:user) }
    let(:note) { build(:note, user: user, content: Faker::Lorem.sentence(word_count: words_to_generate)) }

    context 'when content is shorter than short threshold' do
      let(:words_to_generate) { Faker::Number.between(from: 0, to: utility.short_threshold) }

      it 'returns short' do
        allow(utility).to receive(:short_threshold).and_return(Faker::Number.between(from: 0, to: 1000))
        allow(utility).to receive(:medium_threshold).and_return(Faker::Number.between(from: utility.short_threshold + 1, to: 1000))
        expect(note.content_length).to eq('short')
      end
    end

    context 'when content is in between short and medium thresholds' do
      let(:words_to_generate) { Faker::Number.between(from: utility.short_threshold + 1, to: utility.medium_threshold) }

      it 'returns medium' do
        expect(note.content_length).to eq('medium')
      end
    end

    context 'when content is longer than medium threshold' do
      let(:words_to_generate) { Faker::Number.between(from: utility.medium_threshold + 1) }

      it 'returns long' do
        expect(note.content_length).to eq('long')
      end
    end
  end
end
