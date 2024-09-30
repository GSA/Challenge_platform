# frozen_string_literal: true

require 'rails_helper'

describe "A11y", :js do
  describe "Logged-out" do
    it "web root page is accessible" do
      visit "/"
      expect(page).to(be_axe_clean)
    end

    it "dashboard index page is accessible" do
      visit dashboard_path
      expect(page).to(be_axe_clean)
    end
  end

  describe "Logged-in as a Challenge Manager" do
    let(:user) { create_and_log_in_user(role: "challenge_manager") }

    it "dashboard index page is accessible" do
      visit dashboard_path
      expect(user.role).to eq("challenge_manager")
      expect(page).to(be_axe_clean)
    end
  end

  describe "Logged-in as an Evaluator" do
    let(:user) { create_and_log_in_user(role: "evaluator") }

    it "dashboard index page is accessible" do
      visit dashboard_path
      expect(user.role).to eq("evaluator")
      expect(page).to(be_axe_clean)
    end
  end
end
