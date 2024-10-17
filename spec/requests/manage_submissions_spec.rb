require 'rails_helper'

RSpec.describe "ManageSubmissions" do
  describe "GET /manage_submissions" do
    context "when logged in as a super admin" do
      before do
        create_and_log_in_user(role: "super_admin")
      end

      it "redirects to the phoenix app" do
        get manage_submissions_path

        expect(response).to redirect_to(ENV.fetch("PHOENIX_URI", nil))
      end
    end

    context "when logged in as a admin" do
      before do
        create_and_log_in_user(role: "admin")
      end

      it "redirects to the phoenix app" do
        get manage_submissions_path

        expect(response).to redirect_to(ENV.fetch("PHOENIX_URI", nil))
      end
    end

    context "when logged in as a challenge manager" do
      let(:challenge_user) { create_user(role: "challenge_manager") }

      before { log_in_user(challenge_user) }

      it "renders the index view with the correct header" do
        get manage_submissions_path

        expect(response).to have_http_status(:success)
        expect(response.body).to include("Manage Submissions")
        expect(response.body).to include("View challenge submissions")
      end

      it "renders an empty list" do
        get manage_submissions_path

        expect(response.body).to include("You currently do not have any challenges.")
      end

      it "renders a list of challenges" do
        agency = Agency.create!(name: "Gandalf and Sons", acronym: "GAD")
        challenge = Challenge.create!(user: challenge_user, agency:, title: "Turning monster energy into pepto bismol")
        phase = create_phase(challenge_id: challenge.id)
        ChallengeManager.create(user: challenge_user, challenge:)
        create_evaluation_form(title: "Frodo", challenge_id: challenge.id, phase_id: phase.id)

        get manage_submissions_path
        expect(response.body).to include("Turning monster energy into pepto bismol")
        expect(response.body).to include("Frodo")
      end
    end

    context "when logged in as an evaluator" do
      before do
        create_and_log_in_user(role: "evaluator")
      end

      it "redirects to the dashboard" do
        get manage_submissions_path

        expect(response).to redirect_to(dashboard_path)
      end
    end

    context "when logged in as a solver" do
      before do
        create_and_log_in_user(role: "solver")
      end

      it "redirects to the phoenix app" do
        get manage_submissions_path

        expect(response).to redirect_to(ENV.fetch("PHOENIX_URI", nil))
      end
    end
  end
end
