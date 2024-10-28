require 'rails_helper'

RSpec.describe EvaluatorInvitation, type: :model do
  let(:challenge) { create(:challenge) }
  let(:phase) { create(:phase, challenge:) }

  it "can be created with valid attributes" do
    invitation = build(:evaluator_invitation, challenge:, phase:)
    expect(invitation).to be_valid
    expect { invitation.save! }.to change { described_class.count }.by(1)
  end

  it "can be destroyed" do
    invitation = create(:evaluator_invitation, challenge:, phase:)
    expect { invitation.destroy }.to change { described_class.count }.by(-1)
  end

  it "validates uniqueness of email within challenge and phase" do
    create(:evaluator_invitation, challenge:, phase:, email: "test@example.com")
    duplicate_invitation = build(:evaluator_invitation, challenge:, phase:, email: "test@example.com")
    expect(duplicate_invitation).not_to be_valid
    expect(duplicate_invitation.errors[:email]).to include("has already been taken")
  end

  it "allows the same email for different challenges or phases" do
    create(:evaluator_invitation, challenge:, phase:, email: "test@example.com")
    different_challenge = create(:challenge)
    different_phase = create(:phase, challenge: different_challenge)

    invitation_different_challenge = build(:evaluator_invitation, challenge: different_challenge, phase:,
                                                                  email: "test@example.com")
    expect(invitation_different_challenge).to be_valid

    invitation_different_phase = build(:evaluator_invitation, challenge:, phase: different_phase,
                                                              email: "test@example.com")
    expect(invitation_different_phase).to be_valid
  end

  it "requires a first name" do
    invitation = build(:evaluator_invitation, first_name: nil)
    expect(invitation).not_to be_valid
    expect(invitation.errors[:first_name]).to include("can't be blank")
  end

  it "requires a last name" do
    invitation = build(:evaluator_invitation, last_name: nil)
    expect(invitation).not_to be_valid
    expect(invitation.errors[:last_name]).to include("can't be blank")
  end

  it "requires a valid email" do
    invitation = build(:evaluator_invitation, email: "invalid_email")
    expect(invitation).not_to be_valid
    expect(invitation.errors[:email]).to include("is invalid")
  end
end
