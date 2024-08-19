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

RSpec.describe SecurityLog do
  describe 'Security Log validations' do
    it_behaves_like 'a model with required attributes', [:action]

    it 'sets logged_at before validation on create' do
      security_log = described_class.new(action: 'create')
      expect(security_log).to be_valid
      expect(security_log.logged_at).not_to be_nil
    end
  end
end
