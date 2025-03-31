# frozen_string_literal: true

require 'rails_helper'

describe "A11y", :js do
  let(:user) { nil }

  before do
    system_login_user(user) if user
  end

  describe "Logged-out" do
    xit "web root page is accessible" do
      # Marking as pending as the root page is proxied pages content for now
      visit "/"
      expect(page).to(be_axe_clean)
    end
  end

  describe "Logged-in as a Challenge Manager" do
    let(:user) { create_user(role: "challenge_manager") }

    it "challenge phase index page is accessible" do
      visit phases_path
      expect(user.role).to eq("challenge_manager")
      expect(page).to(be_axe_clean)
    end
  end

  describe "Logged-in as an Evaluator" do
    let(:user) { create_user(role: "evaluator", status: "active") }

    it "evaluations index page is accessible" do
      visit evaluations_path
      expect(user.role).to eq("evaluator")
      expect(page).to(be_axe_clean)
    end
  end
end
