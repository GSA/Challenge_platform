# frozen_string_literal: true

# == Schema Information
#
# Table name: agencies
#
#  id                :bigint           not null, primary key
#  name              :string(255)      not null
#  description       :text
#  avatar_key        :uuid
#  avatar_extension  :string(255)
#  deleted_at        :datetime
#  inserted_at       :datetime         not null
#  updated_at        :datetime         not null
#  created_on_import :boolean          default(FALSE), not null
#  acronym           :string(255)
#  parent_id         :bigint
#
class Agency < ApplicationRecord
  belongs_to :parent, class_name: 'Agency', optional: true
  has_many :sub_agencies, class_name: 'Agency', foreign_key: :parent_id
  has_many :federal_partners, dependent: :destroy
  has_many :federal_partner_challenges, through: :federal_partners, source: :challenge
  has_many :members, dependent: :destroy
  has_many :challenges, dependent: :destroy

  validates :name, presence: true
  validates :acronym, presence: true
end
