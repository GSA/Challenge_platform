# frozen_string_literal: true

# == Schema Information
#
# Table name: winners
#
#  id                    :bigint           not null, primary key
#  phase_winner_id       :bigint
#  name                  :string
#  place_title          :string
#  inserted_at          :datetime         not null
#  updated_at           :datetime         not null
#  image_key            :uuid
#  image_extension      :string
#
class Winner < ApplicationRecord
  belongs_to :phase_winner

  validates :name, presence: true
  validates :place_title, presence: true
end
