require 'rails_helper'

RSpec.describe ChallengePhasesEvaluator, type: :model do
  let(:challenge) { create(:challenge) }
  let(:phase) { create(:phase, challenge: challenge) }
  let(:user) { create(:user, role: :evaluator) }

  it "can be created with valid attributes" do
    evaluator = build(:challenge_phases_evaluator, challenge: challenge, phase: phase, user: user)
    expect(evaluator).to be_valid
    expect { evaluator.save! }.to change(ChallengePhasesEvaluator, :count).by(1)
  end

  it "can be destroyed" do
    evaluator = create(:challenge_phases_evaluator, challenge: challenge, phase: phase, user: user)
    expect { evaluator.destroy }.to change(ChallengePhasesEvaluator, :count).by(-1)
  end

  it "associates the user as an evaluator for the challenge" do
    create(:challenge_phases_evaluator, challenge: challenge, phase: phase, user: user)
    expect(challenge.evaluators).to include(user)
  end

  it "requires a challenge" do
    evaluator = build(:challenge_phases_evaluator, challenge: nil)
    expect(evaluator).not_to be_valid
    expect(evaluator.errors[:challenge]).to include("must exist")
  end

  it "requires a phase" do
    evaluator = build(:challenge_phases_evaluator, phase: nil)
    expect(evaluator).not_to be_valid
    expect(evaluator.errors[:phase]).to include("must exist")
  end

  it "requires a user" do
    evaluator = build(:challenge_phases_evaluator, user: nil)
    expect(evaluator).not_to be_valid
    expect(evaluator.errors[:user]).to include("must exist")
  end

  it "allows multiple evaluators for the same challenge and phase" do
    challenge = create(:challenge)
    phase = create(:phase, challenge: challenge)
    user1 = create(:user, role: :evaluator)
    user2 = create(:user, role: :evaluator)

    evaluator1 = create(:challenge_phases_evaluator, challenge: challenge, phase: phase, user: user1)
    evaluator2 = build(:challenge_phases_evaluator, challenge: challenge, phase: phase, user: user2)

    expect(evaluator2).to be_valid
    expect { evaluator2.save! }.not_to raise_error
  end
end
