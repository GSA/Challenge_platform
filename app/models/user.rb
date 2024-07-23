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
  has_many :challenges
  has_many :challenge_managers
  has_many :challenge_manager_challenges, through: :challenge_managers, source: :challenge
  has_many :members
  has_many :supporting_documents, class_name: 'Document'
  has_many :submissions, foreign_key: :submitter_id
  has_many :managed_submissions, class_name: 'Submission', foreign_key: :manager_id
  has_many :submission_documents, class_name: 'Submissions::Document'
  has_many :message_context_statuses

  attribute :role, :string, default: -> { read_attribute(:role) }
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

  attribute :last_active, :datetime, default: false
  attribute :recertification_expired_at, :datetime, default: false
  attribute :active_session, :boolean, default: false

  attribute :renewal_request, :string

  attribute :created_at, :datetime, precision: 6
  attribute :updated_at, :datetime, precision: 6

  validates :email, presence: true
end
