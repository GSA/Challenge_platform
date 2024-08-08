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

  private

  def set_logged_at
    self.logged_at ||= DateTime.now
  end
end
