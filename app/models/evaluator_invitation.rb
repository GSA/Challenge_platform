# frozen_string_literal: true

# == Schema Information
#
# Table name: evaluator_invitations
#
#  id               :bigint           not null, primary key
#  challenge_id     :bigint           not null
#  phase_id         :bigint           not null
#  first_name       :string           not null
#  last_name        :string           not null
#  email            :string           not null
#  last_invite_sent :datetime         not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
class EvaluatorInvitation < ApplicationRecord
  belongs_to :challenge
  belongs_to :phase

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :last_invite_sent, presence: true

  validates :email, uniqueness: { scope: [:challenge_id, :phase_id] }
end
