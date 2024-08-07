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

  scope :with_note_type, ->(note_type) { where(note_type: note_type) }
  scope :with_pagination, ->(page, page_size) { page(page).per(page_size) }

  def word_count
    content.split.size
  end

  def content_length
    return 'short' if word_count <= utility.short_threshold.to_i
    return 'medium' if word_count <= utility.medium_threshold.to_i
    'long'
  end

  private

  def validate_content_word_count
    return unless note_type == 'review' && content_length != 'short'

    errors.add(:content,
               I18n.t('errors.messages.note.invalid_content_length',
                      threshold: utility.short_threshold))
  end
end
