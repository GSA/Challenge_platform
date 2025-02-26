# frozen_string_literal: true

require 'rails_helper'

describe "A11y", :js do
  describe "Logged-in as a Challenge Manager" do
    let(:user) { create_user(role: "challenge_manager") }

    before { system_login_user(user) }

    it "manage submissions by challenge phase page is accessible with one challenge" do
      challenge = create_challenge(user: user, title: "Boston Tea Party Cleanup")
      phase = create_phase(challenge_id: challenge.id)
      create(:submission, challenge: challenge, phase: phase)

      visit submissions_phase_path(phase)
      expect(user.role).to eq("challenge_manager")
      expect(page).to have_content("Boston Tea Party Cleanup")

      expect(page).to have_content("At a glance")
      expect(page).to have_content("Submissions")
      expect(page).to have_content("Eligible for evaluation")
      expect(page).to have_content("Selected to advance")
      expect(page).to have_content("Evaluation due date")

      expect(page).to(be_axe_clean)
    end
  end
end
