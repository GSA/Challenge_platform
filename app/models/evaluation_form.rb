# frozen_string_literal: true

# == Schema Information
#
# Table name: evaluation_forms
#
#  id                :bigint           not null, primary key
#  title             :string
#  instructions      :string
#  challenge_phase   :integer
#  comments_required :boolean          default(FALSE)
#  weighted_scoring  :boolean          default(FALSE)
#  closing_date      :date
#  challenge_id      :bigint
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
class EvaluationForm < ApplicationRecord
  belongs_to :challenge
  has_many :evaluation_criteria, dependent: nil

  scope :by_user, lambda { |user|
    joins(challenge: :challenge_manager_users).
      where(challenge_manager_users: { id: user.id })
  }

  validates :title, presence: true
  validates :instructions, presence: true
  validates :closing_date, presence: true
  validates :challenge_phase, presence: true
  validates :challenge_phase, uniqueness: { scope: :challenge_id }
end
