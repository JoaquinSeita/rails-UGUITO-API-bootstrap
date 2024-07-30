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
    classify_content
  end

  private

  def classify_content
    return :short if utility.note_is_short?(self)
    return :medium if utility.note_is_medium?(self)
    return :long if utility.note_is_long?(self)
    raise 'Invalid content length'
  end

  def validate_content_word_count
    return if utility.nil? || content.blank?

    return unless note_type == 'review' && content_length != :short

    errors.add(:content, I18n.t('content_length_error'))
  end
end
