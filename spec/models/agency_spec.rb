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
require 'rails_helper'

RSpec.describe Agency do
  describe 'validations' do
    it 'validates presence of name' do
      agency = described_class.new(name: nil, acronym: 'TEST')
      expect(agency).not_to be_valid
      expect(agency.errors[:name]).to include("can't be blank")
    end

    it 'validates presence of acronym' do
      agency = described_class.new(name: 'Test Agency', acronym: nil)
      expect(agency).not_to be_valid
      expect(agency.errors[:acronym]).to include("can't be blank")
    end
  end
end
