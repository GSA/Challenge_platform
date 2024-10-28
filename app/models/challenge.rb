# frozen_string_literal: true

# == Schema Information
#
# Table name: challenges
#
#  id                             :bigint           not null, primary key
#  user_id                        :bigint           not null
#  description                    :text
#  inserted_at                    :datetime         not null
#  updated_at                     :datetime         not null
#  status                         :string(255)      default("draft"), not null
#  captured_on                    :date
#  published_on                   :date
#  title                          :string(255)
#  tagline                        :text
#  poc_email                      :string(255)
#  agency_name                    :string(255)
#  how_to_enter                   :text
#  rules                          :text
#  external_url                   :string(255)
#  custom_url                     :string(255)
#  start_date                     :datetime
#  end_date                       :datetime
#  fiscal_year                    :string(255)
#  type                           :string(255)
#  prize_total                    :bigint           not null
#  prize_description              :text
#  judging_criteria               :text
#  challenge_manager              :string(255)
#  legal_authority                :string(255)
#  terms_and_conditions           :text
#  non_monetary_prizes            :text
#  federal_partners               :text
#  faq                            :text
#  winner_information             :text
#  number_of_phases               :text
#  phase_descriptions             :text
#  phase_dates                    :text
#  brief_description              :text
#  multi_phase                    :boolean
#  eligibility_requirements       :text
#  challenge_manager_email        :string(255)
#  agency_id                      :bigint
#  logo_key                       :uuid
#  logo_extension                 :string(255)
#  winner_image_key               :uuid
#  winner_image_extension         :string(255)
#  last_section                   :string(255)
#  types                          :jsonb
#  auto_publish_date              :datetime
#  deleted_at                     :datetime
#  rejection_message              :text
#  phases                         :jsonb
#  upload_logo                    :boolean
#  is_multi_phase                 :boolean
#  timeline_events                :jsonb
#  prize_type                     :string(255)
#  terms_equal_rules              :boolean
#  how_to_enter_link              :string(255)
#  resource_banner_key            :uuid
#  resource_banner_extension      :string(255)
#  imported                       :boolean          default(FALSE), not null
#  description_delta              :text
#  prize_description_delta        :text
#  faq_delta                      :text
#  eligibility_requirements_delta :text
#  rules_delta                    :text
#  terms_and_conditions_delta     :text
#  uuid                           :uuid
#  sub_agency_id                  :bigint
#  primary_type                   :string(255)
#  other_type                     :string(255)
#  announcement                   :text
#  announcement_datetime          :datetime
#  sub_status                     :string(255)
#  gov_delivery_topic             :string(255)
#  archive_date                   :datetime
#  gov_delivery_subscribers       :integer          default(0), not null
#  brief_description_delta        :text
#  logo_alt_text                  :string(255)
#  short_url                      :string(255)
#  submission_collection_method   :string(255)
#  file_upload_required           :boolean          default(FALSE)
#  upload_instruction_note        :string(255)
#
class Challenge < ApplicationRecord
  belongs_to :user
  belongs_to :agency
  belongs_to :sub_agency, class_name: 'Agency', optional: true

  has_many :events, dependent: :delete_all
  has_many :supporting_documents, class_name: 'Document', dependent: :delete_all
  has_many :challenge_managers, dependent: :delete_all
  has_many :challenge_manager_users, through: :challenge_managers, source: :user
  has_many :federal_partners, dependent: :delete_all
  has_many :federal_partner_agencies, through: :federal_partners, source: :agency
  has_many :non_federal_partners, dependent: :delete_all
  has_many :phases, -> { order(:start_date) }, inverse_of: :challenge, dependent: :destroy
  has_many :submissions, dependent: :destroy
  has_many :submission_exports, dependent: :destroy
  has_many :evaluator_invitations, dependent: :destroy
  has_many :challenge_phases_evaluators, dependent: :destroy
  has_many :evaluators, through: :challenge_phases_evaluators, source: :user

  # JSON fields
  attribute :types, :jsonb
  attribute :timeline_events, :jsonb

  attribute :status, :string, default: "draft"
  attribute :prize_total, :integer, default: 0
  attribute :gov_delivery_subscribers, :integer, default: 0
  attribute :imported, :boolean, default: false
  attribute :uuid, :uuid

  # other fields
  attribute :sub_status, :string
  attribute :last_section, :string
  attribute :challenge_manager, :string
  attribute :challenge_manager_email, :string
  attribute :poc_email, :string
  attribute :agency_name, :string
  attribute :title, :string
  attribute :custom_url, :string
  attribute :external_url, :string
  attribute :tagline, :string
  attribute :type, :string
  attribute :description, :string
  attribute :description_delta, :string
  attribute :description_length, :integer
  attribute :brief_description, :string
  attribute :brief_description_delta, :string
  attribute :brief_description_length, :integer
  attribute :how_to_enter, :string
  attribute :fiscal_year, :string
  attribute :start_date, :datetime
  attribute :end_date, :datetime
  attribute :archive_date, :datetime
  attribute :multi_phase, :boolean
  attribute :number_of_phases, :string
  attribute :phase_descriptions, :string
  attribute :phase_dates, :string
  attribute :judging_criteria, :string
  attribute :prize_type, :string
  attribute :non_monetary_prizes, :string
  attribute :prize_description, :string
  attribute :prize_description_delta, :string
  attribute :prize_description_length, :integer
  attribute :eligibility_requirements, :string
  attribute :eligibility_requirements_delta, :string
  attribute :rules, :string
  attribute :rules_delta, :string
  attribute :terms_and_conditions, :string
  attribute :terms_and_conditions_delta, :string
  attribute :legal_authority, :string
  attribute :faq, :string
  attribute :faq_delta, :string
  attribute :faq_length, :integer
  attribute :winner_information, :string
  attribute :captured_on, :date
  attribute :auto_publish_date, :datetime
  attribute :published_on, :date
  attribute :rejection_message, :string
  attribute :how_to_enter_link, :string
  attribute :announcement, :string
  attribute :announcement_datetime, :datetime
  attribute :gov_delivery_topic, :string
  attribute :short_url, :string
  attribute :upload_logo, :boolean
  attribute :is_multi_phase, :boolean
  attribute :terms_equal_rules, :boolean
  attribute :file_upload_required, :boolean
  attribute :upload_instruction_note, :string
  attribute :submission_collection_method, :string

  attribute :deleted_at, :datetime

  validates :title, presence: true
  validates :status, presence: true
end
