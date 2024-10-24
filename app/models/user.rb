# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                         :bigint           not null, primary key
#  email                      :string(255)      not null
#  password_hash              :string(255)
#  token                      :uuid
#  first_name                 :string(255)
#  last_name                  :string(255)
#  phone_number               :string(255)
#  inserted_at                :datetime         not null
#  updated_at                 :datetime         not null
#  email_verification_token   :string(255)
#  email_verified_at          :datetime
#  role                       :string(255)      default("user"), not null
#  password_reset_token       :uuid
#  password_reset_expires_at  :datetime
#  finalized                  :boolean          default(TRUE), not null
#  avatar_key                 :uuid
#  avatar_extension           :string(255)
#  display                    :boolean          default(TRUE), not null
#  terms_of_use               :datetime
#  privacy_guidelines         :datetime
#  agency_id                  :bigint
#  last_active                :datetime
#  status                     :string(255)
#  active_session             :boolean          default(FALSE)
#  renewal_request            :string(255)
#  jwt_token                  :text
#  recertification_expired_at :datetime
#
class User < ApplicationRecord
  belongs_to :agency, optional: true

  has_many :challenges, dependent: :destroy
  has_many :challenge_managers, dependent: :destroy
  has_many :challenge_manager_challenges, through: :challenge_managers, source: :challenge, dependent: :destroy
  has_many :members, dependent: :destroy
  has_many :supporting_documents, class_name: 'Document', dependent: :destroy
  has_many :submissions, foreign_key: :submitter_id, inverse_of: :submitter, dependent: :destroy
  has_many :evaluator_submission_assignments
  has_many :assigned_submissions, through: :evaluator_submission_assignments, source: :submission
  has_many :managed_submissions,
           class_name: 'Submission',
           foreign_key: :manager_id,
           inverse_of: :manager,
           dependent: :destroy
  has_many :submission_documents, class_name: 'Submissions::Document', dependent: :destroy
  has_many :message_context_statuses, dependent: :destroy
  has_many :challenge_phases_evaluators, dependent: :destroy
  has_many :evaluated_phases, through: :challenge_phases_evaluators, source: :phase

  attribute :role, :string
  attribute :status, :string, default: 'pending'
  attribute :finalized, :boolean, default: true
  attribute :display, :boolean, default: true

  attribute :email, :string
  attribute :password_hash, :string
  attribute :token, :uuid
  attribute :jwt_token, :string

  attribute :email_verification_token, :string
  attribute :email_verified_at, :datetime

  attribute :password_reset_token, :uuid
  attribute :password_reset_expires_at, :datetime

  attribute :first_name, :string
  attribute :last_name, :string
  attribute :phone_number, :string

  attribute :avatar_key, :uuid
  attribute :avatar_extension, :string

  attribute :terms_of_use, :datetime
  attribute :privacy_guidelines, :datetime
  attribute :agency_id, :integer

  attribute :last_active, :datetime
  attribute :recertification_expired_at, :datetime
  attribute :active_session, :boolean, default: false

  attribute :renewal_request, :string

  validates :email, presence: true

  ROLES = %w[super_admin admin challenge_manager evaluator solver].freeze
  validates :role, inclusion: { in: ROLES }

  # Finds, creates, or updates user from userinfo
  # Find in case of user with existing token matching userinfo["sub"]
  # Create in case of no token or email matching in userinfo
  # Update in case of matching email to userinfo["email"] but no token set
  # TODO: Add relevant security log tracking here?
  def self.user_from_userinfo(userinfo)
    email = userinfo[0]["email"]
    token = userinfo[0]["sub"]

    if (user = find_by(token:))
      user
    elsif (user = find_by(email:))
      update_admin_added_user(user, userinfo)
    else
      create_user_from_userinfo(userinfo)
    end
  end

  def self.update_admin_added_user(user, userinfo)
    update(user.id, { token: userinfo[0]["sub"] })
  end

  def self.create_user_from_userinfo(userinfo)
    email = userinfo[0]["email"]
    token = userinfo[0]["sub"]

    default_role, default_status = default_role_and_status_for_email(email)

    create({
             email:,
             role: default_role,
             token:,
             terms_of_use: nil,
             privacy_guidelines: nil,
             status: default_status
           })
  end

  def self.default_role_and_status_for_email(email)
    if default_challenge_manager?(email)
      %w[challenge_manager pending]
    else
      %w[solver active]
    end
  end

  def self.default_challenge_manager?(email)
    /\.(gov|mil)$/.match?(email)
  end
end
