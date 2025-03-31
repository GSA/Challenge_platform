# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "EvaluationOverrides", :js do
  describe "GET /auth/failure_to_proof" do
    context "when logged in as a challenge_manager" do
      let(:user) { create(:user, role: :challenge_manager) }

      before do
        system_login_user(user)
        visit auth_failure_to_proof_path
      end

      it "is accessible" do
        expect(page).to(be_axe_clean)
      end

      it "has an alert banner" do
        expect(page).to have_css(".usa-alert--error")
        expect(page).to have_css(".usa-alert__heading", text: "We can't verify your identity.")
      end

      it "has links to login.gov help and contact" do
        expect(page).to have_link("Login.gov's Help Section", href: "https://login.gov/help")
        expect(page).to have_link("login.gov/contact", href: "https://login.gov/contact")
      end

      it "has a mail link to team@challenge.gov" do
        expect(page).to have_link("team@challenge.gov", href: "mailto:team@challenge.gov")
      end
    end

    context "when logged in as an evaluator" do
      let(:user) { create(:user, role: :evaluator) }

      before do
        system_login_user(user)
        visit auth_failure_to_proof_path
      end

      it "is accessible" do
        expect(page).to(be_axe_clean)
      end

      it "has an alert banner" do
        expect(page).to have_css(".usa-alert--error")
        expect(page).to have_css(".usa-alert__heading", text: "We can't verify your identity.")
      end

      it "has links to login.gov help and contact" do
        expect(page).to have_link("Login.gov's Help Section", href: "https://login.gov/help")
        expect(page).to have_link("login.gov/contact", href: "https://login.gov/contact")
      end

      it "has a mail link to team@challenge.gov" do
        expect(page).to have_link("team@challenge.gov", href: "mailto:team@challenge.gov")
      end
    end
  end
end
