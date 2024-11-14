# frozen_string_literal: true

require 'rails_helper'

describe "A11y", :js do
  let(:user) { nil }

  before do
    system_login_user(user) if user
  end

  describe "Logged-in as a Challenge Manager" do
    let(:user) { create_user(role: "challenge_manager") }

    it "manage submissions index page is accessible with no challenges" do
      visit phases_path
      expect(user.role).to eq("challenge_manager")
      expect(page).to(be_axe_clean)
    end

    it "manage submissions index page is accessible with one challenge" do
      challenge = create_challenge(user: user, title: "Boston Tea Party Cleanup")
      create_phase(challenge_id: challenge.id)

      visit phases_path
      expect(user.role).to eq("challenge_manager")
      expect(page).to have_content("Boston Tea Party Cleanup")
      expect(page).to(be_axe_clean)
    end

    it "manage submissions by challenge phase page is accessible with one challenge" do
      challenge = create_challenge(user: user, title: "Boston Tea Party Cleanup")
      phase = create_phase(challenge_id: challenge.id)

      visit submissions_phase_path(phase)
      expect(user.role).to eq("challenge_manager")
      expect(page).to have_content("Boston Tea Party Cleanup")
      expect(page).to(be_axe_clean)
    end
  end
end
