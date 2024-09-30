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
  belongs_to :challenge, optional: true

  scope :by_user, lambda { |user|
    joins(challenge: :challenge_manager_users).
      where(challenge_manager_users: { id: user.id })
  }
end
