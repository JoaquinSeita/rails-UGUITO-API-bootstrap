# == Schema Information
#
# Table name: notes
#
#  id         :bigint(8)        not null, primary key
#  title      :string
#  content    :string
#  note_type  :string
#  user_id    :bigint(8)        not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Note < ApplicationRecord
  TYPES_ATTRIBUTES = %w[review critique].freeze

  validates :title, :content, :note_type, :user_id, presence: true
  validates :note_type, inclusion: { in: TYPES_ATTRIBUTES, message: 'not a valid type' }

  belongs_to :user
  has_one :utility, through: :user
end
