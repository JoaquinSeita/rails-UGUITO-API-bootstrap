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

  describe '#validate_content_word_count' do
    it 'validates word count' do
      expect(subject.word_count).to be_kind_of(Integer)
    end

    it 'validates content length' do
      expect(subject.content_length).to be_in(%w[short medium long])
    end

    context 'when note type is review and content length is not short' do
      let(:note) { build(:note, note_type: :review, content: '') }

      it 'adds an error to the content attribute' do
        note.valid?
        expect(note.errors[:content]).to include(I18n.t('content_length_error'))
      end
    end

    context 'when note type is review and content length is short' do
      let(:note) { build(:note, note_type: :review, content: 'This is a short content') }

      it 'does not add an error to the content attribute' do
        note.valid?
        expect(note.errors[:content]).not_to include(I18n.t('content_length_error'))
      end
    end
  end

  it 'has a valid factory' do
    expect(subject).to be_valid
  end
end
