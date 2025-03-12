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

  validate :validate_full_name
  validate :validate_email
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

  private

  def validate_full_name
    return if first_name.present? && last_name.present?

    errors.add(:full_name, I18n.t('evaluators.error.full_name'))
  end

  def validate_email
    return if email.present? && email =~ URI::MailTo::EMAIL_REGEXP

    errors.add(:email, I18n.t('evaluators.error.email_address'))
  end
end
