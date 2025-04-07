# frozen_string_literal: true

# == Schema Information
#
# Table name: security_log
#
#  id                    :bigint           not null, primary key
#  action                :string(255)      not null
#  details               :jsonb
#  originator_id         :bigint
#  originator_role       :string(255)
#  originator_identifier :string(255)
#  target_id             :integer
#  target_type           :string(255)
#  target_identifier     :string(255)
#  logged_at             :datetime         not null
#  originator_remote_ip  :string(255)
#

# originator id, role, and identifier (email) are from the user that initiated the action
#
# target id, type (user, challenge, submission, etc), identifier (email, challenge title, etc)
# are the record the action is being performed on
#
# Actions and their possible details
# status_change
# - Used for status changes in records (evaluations)
# - Details:
#   - status: the status the record was changed to
#   - previous_status: status a record was before changing
#   - new_status: status a record was changed to
#
# account_update
# - Used when terms are updated for a user
# - Details:
#   - terms_of_use: boolean if they accepted
#   - privacy_guidelines: boolean for if they accepted
#   - first_name: user first name
#   - last_name: user last name
#
# role_change
# - Used when the role of a user is changed
# - Details:
#   - previous_role: the role a user was
#   - new_role: the role a user was changed to
#
# accessed_site
# - Used when a user logs in. Also when an admin updates a user (Intended?)
# - No details
#
# session_duration
# - Used when a user logs out or has a session timeout
# - Details:
#   - duration: the difference in time from when the user last had an accesed_site action
#
# create
# - Used when a challenge is created or a dap_report is uploaded
# - Details:
#   - upload: for dap reports value "site analytics report (DAP)"
#
# read
# - Used when a challenge is viewed
# - No details
#
# update
# - Used when a challenge is updated
# - Details:
#   - action: used in challenge wizard (back, save_draft, etc)
#   - section: the section of the wizard the action occured on
#
# delete
# - Used when a challenge is soft deleted
# - No details
#
# submit
# - Used when a submission is submitted
# - No details
#
# renewal_request
# - Used when a user requests recertification
# - Details:
#   - renewal_requested: Type of recertification requested (recertification, reactivation)
#     and if it was approved (Recertification Approved)
class SecurityLog < ApplicationRecord
  self.table_name = 'security_log'

  belongs_to :originator, class_name: 'User', optional: true

  ROLES = %w[
    status_change account_update role_change accessed_site session_duration
    create read update delete submit renewal_request
  ].freeze

  validates :action, presence: true, inclusion: { in: ROLES }
  validates :logged_at, presence: true

  before_validation :set_logged_at, on: :create

  # Attributes
  attribute :action, :string
  attribute :details, :jsonb
  attribute :originator_id, :integer
  attribute :originator_role, :string
  attribute :originator_identifier, :string
  attribute :originator_remote_ip, :string
  attribute :target_id, :integer
  attribute :target_type, :string
  attribute :target_identifier, :string
  attribute :logged_at, :datetime

  def self.log_event(action:, originator: nil, remote_ip: nil, target: nil, details: {})
    details = details.merge({ ial_level: originator&.ial_level_for_database })

    create!(
      action:,
      originator_id: originator&.id,
      originator_role: originator_role(originator),
      originator_identifier: originator&.email,
      originator_remote_ip: remote_ip,
      target_id: target&.id,
      target_type: target&.class&.name,
      target_identifier: target_identifier(target),
      logged_at: Time.current.utc,
      details:
    )
  end

  def self.timestamp_attributes_for_create
    super + %w[logged_at]
  end

  def self.originator_role(originator)
    return nil unless originator

    if %w[challenge_manager evaluator].include?(originator.role) && originator.non_gov?
      return "#{originator.role}_ng"
    end

    originator.role
  end

  def self.target_identifier(target)
    return nil unless target

    case target
    when User
      target.email
    when Challenge
      target.title
    else
      target.id.to_s
    end
  end

  private

  def set_logged_at
    self.logged_at ||= DateTime.now
  end
end
