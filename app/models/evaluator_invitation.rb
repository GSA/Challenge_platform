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

  def self.split_full_name(name)
    names = name.to_s.strip.split(/\s+/, 2)
    [names[0], names[1]]
  end

  def full_name=(name)
    self.first_name, self.last_name = self.class.split_full_name(name)
  end

  def full_name
    "#{first_name} #{last_name}".strip
  end
end
