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

    it 'allows logging of event with no target' do
      user = create(:user)

      event = described_class.log_event(action: "accessed_site", originator: user, remote_ip: "127.0.0.1")

      expect(event.action).to eq("accessed_site")
      expect(event.originator_id).to eq(user.id)
      expect(event.originator_role).to eq(described_class.originator_role(user))
      expect(event.originator_identifier).to eq(user.email)
      expect(event.originator_remote_ip).to eq("127.0.0.1")
    end

    it 'allows logging of an event with a target and details' do
      user = create(:user)
      challenge = create(:challenge)

      event = described_class.log_event(action: 'create', originator: user, target: challenge, remote_ip: "127.0.0.1",
                                        details: { status: challenge.status })

      expect(event.action).to eq("create")
      expect(event.originator_id).to eq(user.id)
      expect(event.originator_role).to eq(described_class.originator_role(user))
      expect(event.originator_identifier).to eq(user.email)
      expect(event.originator_remote_ip).to eq("127.0.0.1")

      expect(event.target_id).to eq(challenge.id)
      expect(event.target_type).to eq("Challenge")
      expect(event.target_identifier).to eq(challenge.title)
      expect(event.details["status"]).to eq(challenge.status)
    end
  end
end
