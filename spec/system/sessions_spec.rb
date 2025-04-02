# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Sessions", :js do
  describe "POST /session" do
    context "when logging in as a gov challenge_manager" do
      let(:user) { create(:user, :challenge_manager, :gov) }

      before do
        system_login_user(user)
      end

      it "creates an accessed_site security log event on login" do
        login_event = SecurityLog.where(action: "accessed_site").first

        expect(SecurityLog.count).to eq(1)
        expect(login_event.action).to eq("accessed_site")
        expect(login_event.originator_id).to eq(user.id)
        expect(login_event.originator_role).to eq(user.role)
        expect(login_event.originator_identifier).to eq(user.email)
      end
    end

    context "when logging in as a non_gov challenge_manager" do
      let(:user) { create(:user, :challenge_manager, :non_gov) }

      before do
        system_login_user(user)
      end

      it "creates an accessed_site security log event on login" do
        login_event = SecurityLog.where(action: "accessed_site").first

        expect(SecurityLog.count).to eq(1)
        expect(login_event.action).to eq("accessed_site")
        expect(login_event.originator_id).to eq(user.id)
        expect(login_event.originator_role).to eq("#{user.role}_ng")
        expect(login_event.originator_identifier).to eq(user.email)
      end
    end

    context "when logging in as a gov evaluator" do
      let(:user) { create(:user, :evaluator, :gov) }

      before do
        system_login_user(user)
      end

      it "creates an accessed_site security log event on login" do
        login_event = SecurityLog.where(action: "accessed_site").first

        expect(SecurityLog.count).to eq(1)
        expect(login_event.action).to eq("accessed_site")
        expect(login_event.originator_id).to eq(user.id)
        expect(login_event.originator_role).to eq(user.role)
        expect(login_event.originator_identifier).to eq(user.email)
      end
    end

    context "when logging in as a non_gov evaluator" do
      let(:user) { create(:user, :evaluator, :non_gov) }

      before do
        system_login_user(user)
      end

      it "creates an accessed_site security log event on login" do
        login_event = SecurityLog.where(action: "accessed_site").first

        expect(SecurityLog.count).to eq(1)
        expect(login_event.action).to eq("accessed_site")
        expect(login_event.originator_id).to eq(user.id)
        expect(login_event.originator_role).to eq("#{user.role}_ng")
        expect(login_event.originator_identifier).to eq(user.email)
      end
    end
  end

  describe "DELETE /session" do
    context "when logging out as a gov challenge_manager" do
      let(:user) { create(:user, :challenge_manager, :gov) }

      before do
        system_login_user(user)
      end

      it "creates a session_duration security log event on logout" do
        system_logout
        logout_event = SecurityLog.where(action: "session_duration").first

        expect(SecurityLog.count).to eq(2)
        expect(logout_event.action).to eq("session_duration")
        expect(logout_event.originator_id).to eq(user.id)
        expect(logout_event.originator_role).to eq(user.role)
        expect(logout_event.originator_identifier).to eq(user.email)
        expect(logout_event.details["duration"]).not_to be_nil
      end
    end

    context "when logging out as a non_gov challenge_manager" do
      let(:user) { create(:user, :challenge_manager, :non_gov) }

      before do
        system_login_user(user)
      end

      it "creates a session_duration security log event on logout" do
        system_logout
        logout_event = SecurityLog.where(action: "session_duration").first

        expect(SecurityLog.count).to eq(2)
        expect(logout_event.action).to eq("session_duration")
        expect(logout_event.originator_id).to eq(user.id)
        expect(logout_event.originator_role).to eq("#{user.role}_ng")
        expect(logout_event.originator_identifier).to eq(user.email)
        expect(logout_event.details["duration"]).not_to be_nil
      end
    end

    context "when logging out as a gov evaluator" do
      let(:user) { create(:user, :evaluator, :gov) }

      before do
        system_login_user(user)
      end

      it "creates a session_duration security log event on logout" do
        system_logout
        logout_event = SecurityLog.where(action: "session_duration").first

        expect(SecurityLog.count).to eq(2)
        expect(logout_event.action).to eq("session_duration")
        expect(logout_event.originator_id).to eq(user.id)
        expect(logout_event.originator_role).to eq(user.role)
        expect(logout_event.originator_identifier).to eq(user.email)
        expect(logout_event.details["duration"]).not_to be_nil
      end
    end

    context "when logging out as a non_gov evaluator" do
      let(:user) { create(:user, :evaluator, :non_gov) }

      before do
        system_login_user(user)
      end

      it "creates a session_duration security log event on logout" do
        system_logout
        logout_event = SecurityLog.where(action: "session_duration").first

        expect(SecurityLog.count).to eq(2)
        expect(logout_event.action).to eq("session_duration")
        expect(logout_event.originator_id).to eq(user.id)
        expect(logout_event.originator_role).to eq("#{user.role}_ng")
        expect(logout_event.originator_identifier).to eq(user.email)
        expect(logout_event.details["duration"]).not_to be_nil
      end
    end
  end

  describe "GET /auth/failure_to_proof" do
    context "when logged in as a challenge_manager" do
      let(:user) { create(:user, :challenge_manager) }

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
      let(:user) { create(:user, :gov, :evaluator) }

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
