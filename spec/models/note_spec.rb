require 'rails_helper'

RSpec.describe Note, type: :model do
  subject(:note) do
    create(:note)
  end

  it { is_expected.to belong_to(:user) }
  it { is_expected.to have_one(:utility).through(:user) }

  %i[user_id title content note_type].each do |value|
    it { is_expected.to validate_presence_of(value) }
  end

  it 'has a valid factory' do
    expect(subject).to be_valid
  end
end
