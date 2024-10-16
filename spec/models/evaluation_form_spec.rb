# == Schema Information
#
# Table name: evaluation_forms
#
#  id                :bigint           not null, primary key
#  title             :string
#  instructions      :string
#  phase_id          :integer
#  comments_required :boolean          default(FALSE)
#  weighted_scoring  :boolean          default(FALSE)
#  closing_date      :date
#  challenge_id      :bigint
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
require 'rails_helper'

RSpec.describe EvaluationForm do
  describe 'validations' do
    it 'validates presence of title' do
      evaluation_form = described_class.new(title: nil)
      expect(evaluation_form).not_to be_valid
      expect(evaluation_form.errors[:title]).to include("can't be blank")
    end

    it 'validates presence of instructions' do
      evaluation_form = described_class.new(instructions: nil)
      expect(evaluation_form).not_to be_valid
      expect(evaluation_form.errors[:instructions]).to include("can't be blank")
    end

    it 'validates presence of closing date' do
      evaluation_form = described_class.new(closing_date: nil)
      expect(evaluation_form).not_to be_valid
      expect(evaluation_form.errors[:closing_date]).to include("can't be blank")
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
        evaluation_form = create_evaluation_form(challenge_id: challenge.id, challenge_phase: 1)
        expect(challenge.challenge_manager_users).not_to include(different_user)
        expect(described_class.by_user(different_user)).not_to include(evaluation_form)
      end
    end
  end
end
