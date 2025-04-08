# == Schema Information
#
# Table name: evaluation_forms
#
#  id                :bigint           not null, primary key
#  instructions      :string           not null
#  comments_required :boolean          default(FALSE)
#  closing_date      :date             not null
#  challenge_id      :bigint           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  phase_id          :bigint           not null
#  scale_type        :string
#
require 'rails_helper'

RSpec.describe EvaluationForm do
  describe 'validations' do
    it 'validates presence of instructions' do
      evaluation_form = described_class.new(instructions: nil)
      expect(evaluation_form).not_to be_valid
      expect(evaluation_form.errors[:instructions]).to include("Provide evaluation instructions")
    end

    it 'validates presence of closing date' do
      evaluation_form = described_class.new(closing_date: nil)
      expect(evaluation_form).not_to be_valid
      expect(evaluation_form.errors[:closing_date]).to include("Provide closing date")
    end

    it 'validates the presence of a phase' do
      phase = create(:phase)
      evaluation_form = create(:evaluation_form, phase:)
      expect(evaluation_form.phase).to eq(phase)
    end

    it 'requires a phase to be unique' do
      phase = create(:phase)
      create(:evaluation_form, phase:)

      expect do
        create(:evaluation_form, phase:)
      end.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Phase has already been taken")
    end
  end

  describe "scope" do
    describe "#by_user" do
      it 'returns an empty list when there are no forms' do
        user = create_user(role: :challenge_manager)
        assert_empty described_class.by_user(user)
      end

      it 'returns the form for the user' do
        user = create_user(role: :challenge_manager)
        challenge = create_challenge(user:)
        phase = create_phase(challenge:)
        evaluation_form = create_evaluation_form(challenge_id: challenge.id, phase_id: phase.id)
        expect(challenge.challenge_manager_users).to include(user)
        expect(described_class.by_user(user)).to include(evaluation_form)
      end

      it 'does not return the form for an unassociated user' do
        challenge_user = create_user(role: :challenge_manager, email: "user1@example.com")
        different_user = create_user(role: :challenge_manager, email: "user2@example.com")
        challenge = create_challenge(user: challenge_user)
        evaluation_form = create_evaluation_form(challenge_id: challenge.id)
        expect(challenge.challenge_manager_users).not_to include(different_user)
        expect(described_class.by_user(different_user)).not_to include(evaluation_form)
      end
    end
  end
end
