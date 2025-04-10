# frozen_string_literal: true

# == Schema Information
#
# Table name: federal_partners
#
#  id            :bigint           not null, primary key
#  challenge_id  :bigint           not null
#  agency_id     :bigint           not null
#  sub_agency_id :bigint
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
class FederalPartner < ApplicationRecord
  belongs_to :challenge
  belongs_to :agency
  belongs_to :sub_agency, class_name: 'Agency', optional: true
end
