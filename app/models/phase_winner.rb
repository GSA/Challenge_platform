# frozen_string_literal: true

# == Schema Information
#
# Table name: phase_winners
#
#  id                      :bigint           not null, primary key
#  phase_id               :bigint
#  uuid                   :uuid             not null
#  status                 :string
#  overview               :text
#  overview_delta         :text
#  inserted_at           :datetime         not null
#  updated_at            :datetime         not null
#  overview_image_key     :uuid
#  overview_image_extension :string
#
class PhaseWinner < ApplicationRecord
  belongs_to :phase
  has_many :winners, dependent: :destroy

  validates :uuid, presence: true
  validates :phase_id, uniqueness: true
end
