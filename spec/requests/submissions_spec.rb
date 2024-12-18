require 'rails_helper'

RSpec.describe "Submissions" do
  let(:user) { nil }
  let(:challenge) { create_challenge(user: user, title: "Boston Tea Party Cleanup") }
  let(:phase) { create_phase(challenge_id: challenge.id) }

  before { log_in_user(user) }

  describe "GET /phases/:id/submissions" do
    context "when logged in as a super admin" do
      let(:user) { create_user(role: "super_admin") }

      it "redirects to the phoenix app" do
        get phases_path

        expect(response).to redirect_to(ENV.fetch("PHOENIX_URI", nil))
      end
    end

    context "when logged in as a admin" do
      let(:user) { create_user(role: "admin") }

      it "redirects to the phoenix app" do
        get phases_path

        expect(response).to redirect_to(ENV.fetch("PHOENIX_URI", nil))
      end
    end

    context "when logged in as a challenge manager" do
      let(:user) { create_user(role: "challenge_manager") }

      it "renders an empty list of submissions for a user's challenge" do
        get submissions_phase_path(phase)
        expect(response.body).to include("Boston Tea Party Cleanup")

        expect(response.body).to include("No submissions found.")
      end

      it "renders a list of submissions for a user's challenge" do
        submission = create(:submission, challenge: challenge, phase: phase)

        get submissions_phase_path(phase)
        expect(response.body).to include("Boston Tea Party Cleanup")
        expect(response.body).to include(submission.id.to_s)
      end

      it "does not render submissions for a challenge the user is not assigned to" do
        challenge = create_challenge(title: "Star Spangled Banister")
        phase = create_phase(challenge_id: challenge.id)

        get submissions_phase_path(phase)
        expect(response).to have_http_status(:not_found)
      end

      it "renders submission statistics" do
        create(:submission, challenge: challenge, phase: phase)
        create(:submission, challenge: challenge, phase: phase, judging_status: "selected")

        get submissions_phase_path(phase)
        expect(response.body).to include("Boston Tea Party Cleanup")
        # total submission count
        expect(response.body).to have_css("h3.text-primary", text: "Total Submissions")
        expect(response.body).to have_css("span.font-sans-3xl.text-primary.text-bold", text: "2")
        # selected to advance
        expect(response.body).to have_css("span.text-primary", text: "1 of 2")
      end
    end

    context "when logged in as an evaluator" do
      let(:user) { create_user(role: "evaluator") }

      it "redirects to the dashboard" do
        get submissions_phase_path(phase)

        expect(response).to redirect_to(dashboard_path)
      end
    end

    context "when logged in as a solver" do
      let(:user) { create_user(role: "solver") }

      it "redirects to the phoenix app" do
        get submissions_phase_path(phase)

        expect(response).to redirect_to(ENV.fetch("PHOENIX_URI", nil))
      end
    end
  end

  describe "GET /submissions/:id" do
    context "when logged in as a challenge manager" do
      let(:user) { create_user(role: "challenge_manager") }

      it "renders a details page for an individual submission" do
        submission = create(:submission, challenge: phase.challenge, brief_description: "This submission has legs.")

        get submission_path(submission)
        expect(response.body).to include(submission.id.to_s)
        expect(response.body).to include(submission.brief_description)
      end

      it "does not render submission details for a challenge the user is not assigned to" do
        challenge = create_challenge
        phase = create_phase(challenge_id: challenge.id)
        submission = create(:submission, challenge: phase.challenge, brief_description: "This submission has teeth.")

        get submission_path(submission)
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
