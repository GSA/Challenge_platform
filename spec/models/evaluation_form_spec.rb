# == Schema Information
#
# Table name: evaluation_forms
#
#  id                :bigint           not null, primary key
#  title             :string
#  instructions      :string
#  challenge_phase   :integer
#  comments_required :boolean          default(FALSE)
#  weighted_scoring  :boolean          default(FALSE)
#  closing_date      :date
#  challenge_id      :bigint
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
require 'rails_helper'

RSpec.describe EvaluationForm, type: :model do
  describe 'validations' do
    it 'validates nothing' do
      evaluation_form = described_class.new
      expect(evaluation_form).to be_valid
    end
  end

  context "scope" do
    describe "by_user scope" do
      it 'returns an empty list when there are no forms' do
        user = create_user(role: :challenge_manager)
        assert_empty EvaluationForm.by_user(user)
      end

      it 'returns the form for the user' do
        user = create_user(role: :challenge_manager)
        challenge = create_challenge(user:)
        evaluation_form = EvaluationForm.create!(challenge:, challenge_phase: 1)
        expect(challenge.challenge_manager_users).to include(user)
        expect(EvaluationForm.by_user(user)).to include(evaluation_form)
      end

      it 'does not return the form for an unassociated user' do
        challenge_user = create_user(role: :challenge_manager, email: "user1@example.com")
        different_user = create_user(role: :challenge_manager, email: "user2@example.com")
        challenge = create_challenge(user: challenge_user)
        evaluation_form = EvaluationForm.create!(challenge:, challenge_phase: 1)
        expect(challenge.challenge_manager_users).not_to include(different_user)
        expect(EvaluationForm.by_user(different_user)).not_to include(evaluation_form)
      end
    end
  end
end
