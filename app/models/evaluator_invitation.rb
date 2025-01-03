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
#  last_invite_sent :datetime
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

  def full_name=(name)
    names = name.to_s.strip.split(/\s+/, 2)
    self.first_name = names[0]
    self.last_name = names[1]
  end

  def full_name
    "#{first_name} #{last_name}".strip
  end
end
