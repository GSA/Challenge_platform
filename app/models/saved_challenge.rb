# frozen_string_literal: true

# == Schema Information
#
# Table name: saved_challenges
#
#  id           :bigint           not null, primary key
#  user_id      :bigint           not null
#  challenge_id :bigint           not null
#  inserted_at  :datetime         not null
#  updated_at   :datetime         not null
#
class SavedChallenge < ApplicationRecord
  belongs_to :challenge
  belongs_to :user

  # Validations
  validates :user_id, uniqueness: { scope: :challenge_id, message: 'has already saved this challenge' }
end
