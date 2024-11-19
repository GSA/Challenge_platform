require 'rails_helper'

RSpec.describe ChallengePhasesEvaluator, type: :model do
  let(:challenge) { create(:challenge) }
  let(:phase) { create(:phase, challenge:) }
  let(:user) { create(:user, role: :evaluator) }

  it "can be created with valid attributes" do
    evaluator = build(:challenge_phases_evaluator, challenge:, phase:, user:)
    expect(evaluator).to be_valid
    expect { evaluator.save! }.to change { described_class.count }.by(1)
  end

  it "can be destroyed" do
    evaluator = create(:challenge_phases_evaluator, challenge:, phase:, user:)
    expect { evaluator.destroy }.to change { described_class.count }.by(-1)
  end

  it "associates the user as an evaluator for the challenge" do
    create(:challenge_phases_evaluator, challenge:, phase:, user:)
    expect(challenge.evaluators).to include(user)
  end

  it "allows multiple evaluators for the same challenge and phase" do
    challenge = create(:challenge)
    phase = create(:phase, challenge:)
    user1 = create(:user, role: :evaluator)
    user2 = create(:user, role: :evaluator)

    create(:challenge_phases_evaluator, challenge:, phase:, user: user1)
    evaluator2 = build(:challenge_phases_evaluator, challenge:, phase:, user: user2)

    expect(evaluator2).to be_valid
    expect { evaluator2.save! }.not_to raise_error
  end

  it "associates a user as an evaluator for a specific challenge phase" do
    challenge = create(:challenge)
    phase = create(:phase, challenge: challenge)
    user = create(:user, role: 'evaluator')
    create(:challenge_phases_evaluator, challenge: challenge, phase: phase, user: user)

    expect(challenge.evaluators).to include(user)
    expect(phase.evaluators).to include(user)
    expect(user.evaluated_phases).to include(phase)
  end

  context "with invalid user role" do
    let(:invalid_user) { create(:user, role: 'admin') }

    it "is invalid" do
      evaluator = build(:challenge_phases_evaluator, challenge:, phase:, user: invalid_user)
      expect(evaluator).not_to be_valid
      expect(evaluator.errors[:user]).to include("must have a valid evaluator role")
    end
  end

  User::VALID_EVALUATOR_ROLES.each do |role|
    context "with #{role} role" do
      let(:valid_user) { create(:user, role: role) }

      it "is valid" do
        evaluator = build(:challenge_phases_evaluator, challenge:, phase:, user: valid_user)
        expect(evaluator).to be_valid
      end
    end
  end
end
