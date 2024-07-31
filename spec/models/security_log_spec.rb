require 'rails_helper'

RSpec.describe SecurityLog, type: :model do
  describe 'validations' do
    it 'validates presence of action' do
      security_log = described_class.new(action: nil)
      expect(security_log).not_to be_valid
      expect(security_log.errors[:action]).to include("can't be blank")
    end
  end
end
