# spec/helpers/evaluators_helper_spec.rb

require 'rails_helper'

RSpec.describe EvaluatorsHelper, type: :helper do
  describe '#user_status' do
    it 'returns "Invite Sent" for non-User objects' do
      expect(helper.user_status(nil)).to eq("Invite Sent")
    end

    it 'returns "Available" for active users' do
      user = create(:user, status: 'active')
      expect(helper.user_status(user)).to eq("Available")
    end

    it 'returns "Awaiting Approval" for non-active users' do
      user = create(:user, status: 'pending')
      expect(helper.user_status(user)).to eq("Awaiting Approval")
    end
  end
end
