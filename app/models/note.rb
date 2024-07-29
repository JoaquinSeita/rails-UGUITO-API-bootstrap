# == Schema Information
#
# Table name: notes
#
#  id         :bigint(8)        not null, primary key
#  title      :string           not null
#  content    :string           not null
#  note_type  :integer          not null
#  user_id    :bigint(8)        not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Note < ApplicationRecord
  belongs_to :user
  has_one :utility, through: :user
  enum note_type: { review: 0, critique: 1 }
  validates :user_id, :title, :content, :note_type, presence: true
  validate :validate_content_word_count

  private

  def max_content_word_count
    case utility
    when NorthUtility
      { 'review' => 50 }
    when SouthUtility
      { 'review' => 60 }
    end
  end

  def word_count
    content.split(' ').size
  end

  def validate_content_word_count
    return if user_id.blank? || content.blank?

    max_words = max_content_word_count['review']

    return unless note_type == 'review' && word_count > max_words

    errors.add(:content, I18n.t('content_length_error'))
  end

  def classify_content(thresholds)
    word_count = self.word_count

    case word_count
    when 0..thresholds['short']
      :short
    when (thresholds['short'] + 1)..thresholds['medium']
      :medium
    else
      :long
    end
  end

  def classify_north_utility_note_content
    classify_content(
      { 'short' => 50, 'medium' => 100 }
    )
  end

  def classify_south_utility_note_content
    classify_content(
      { 'short' => 60, 'medium' => 120 }
    )
  end

  def content_length
    return if user_id.blank?

    case utility
    when NorthUtility
      classify_north_utility_note_content
    when SouthUtility
      classify_south_utility_note_content
    end
  end
end
