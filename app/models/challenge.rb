# == Schema Information
#
# Table name: challenges
#
#  id                             :bigint           not null, primary key
#  user_id                        :bigint           not null
#  description                    :text
#  inserted_at                    :datetime         not null
#  updated_at                     :datetime         not null
#  status                         :string(255)      default("pending"), not null
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
end
