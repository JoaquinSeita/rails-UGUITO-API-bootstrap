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

  def word_count
    content.split.size
  end

  def content_length
    return if utility.nil?
    classify_content(utility.content_thresholds)
  end
  
  private
  
  def classify_content(thresholds)
    case word_count
    when 0..thresholds['short']
      :short
    when (thresholds['short'] + 1)..thresholds['medium']
      :medium
    else
      :long
    end
  end

  def validate_content_word_count
    return if utility.nil? || content.blank?

    return unless note_type == 'review' && word_count > utility.max_content_word_count[note_type]

    errors.add(:content, I18n.t('content_length_error'))
  end

end
