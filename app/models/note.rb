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
  validate :validate_content_word_count, if: -> { utility.present? && content.present? }

  def word_count
    content.split.size
  end

  def content_length
    return 'short' if word_count <= utility.short_threshold
    return 'medium' if word_count <= utility.medium_threshold
    'long'
  end

  private

  def validate_content_word_count
    return unless note_type == 'review' && content_length != 'short'

    errors.add(:content, I18n.t('content_length_error'))
  end
end
