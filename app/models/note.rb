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
  validate :content_length

  private

  def word_count
    content.split(' ').size
  end

  def validate_max_words(max_word_counts)
    return unless note_type == 'review' && word_count > max_word_counts['review']
    errors.add(:content, I18n.t('content_length_error'))
  end

  def utility_validation(max_word_counts, thresholds)
    word_count = self.word_count
    validate_max_words(max_word_counts)

    case word_count
    when 0..thresholds['short']
      :short
    when (thresholds['short'] + 1)..thresholds['medium']
      :medium
    else
      :long
    end
  end

  def validate_north_utility
    utility_validation(
      { 'review' => 50 },
      { 'short' => 50, 'medium' => 100 }
    )
  end

  def validate_south_utility
    utility_validation(
      { 'review' => 60 },
      { 'short' => 60, 'medium' => 120 }
    )
  end

  def content_length
    return if user_id.blank?

    case utility.code
    when 1
      validate_north_utility
    when 2
      validate_south_utility
    end
  end
end
