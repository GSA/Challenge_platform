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
require 'rails_helper'

RSpec.describe SecurityLog, type: :model do
  describe 'Security Log validations' do
    it 'validates presence of action' do
      security_log = described_class.new(action: nil)
      expect(security_log).not_to be_valid
      expect(security_log.errors[:action]).to include("can not be blank")
    end
  end
end
