# frozen_string_literal: true

# == Schema Information
#
# Table name: evaluation_forms
#
#  id                :bigint           not null, primary key
#  title             :string
#  instructions      :string
#  phase_id   :integer
#  comments_required :boolean          default(FALSE)
#  weighted_scoring  :boolean          default(FALSE)
#  closing_date      :date
#  challenge_id      :bigint
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
class EvaluationForm < ApplicationRecord
  belongs_to :challenge
  belongs_to :phase
  has_many :evaluation_criteria, dependent: :destroy, class_name: "EvaluationCriterion"

  scope :by_user, lambda { |user|
    joins(challenge: :challenge_manager_users).
      where(challenge_manager_users: { id: user.id })
  }

  validates :title, presence: true, length: {maximum: 150}
  validates :instructions, presence: true
  validates :closing_date, presence: true
end
