require 'rails_helper'

RSpec.describe "Evaluations" do
  describe "GET /index" do
    context "when logged in as an super admin" do
      before do
        create_and_log_in_user(role: "super_admin")
      end

      it "redirects to the phoenix app" do
        get evaluations_path

        expect(response).to redirect_to(ENV.fetch("PHOENIX_URI", nil))
      end
    end

    context "when logged in as an admin" do
      before do
        create_and_log_in_user(role: "admin")
      end

      it "redirects to the phoenix app" do
        get evaluations_path

        expect(response).to redirect_to(ENV.fetch("PHOENIX_URI", nil))
      end
    end

    context "when logged in as a challenge manager" do
      before do
        create_and_log_in_user(role: "challenge_manager")
      end

      it "redirects to the dashboard" do
        get evaluations_path

        expect(response).to redirect_to(dashboard_path)
      end
    end

    context "when logged in as an evaluator" do
      before do
        create_and_log_in_user(role: "evaluator")
      end

      it "renders the index view with the correct header" do
        get evaluations_path

        expect(response).to have_http_status(:success)
        expect(response.body).to include("Evaluations")
      end
    end

    context "when logged in as a solver" do
      before do
        create_and_log_in_user(role: "solver")
      end

      it "redirects to the phoenix app" do
        get evaluations_path

        expect(response).to redirect_to(ENV.fetch("PHOENIX_URI", nil))
      end
    end
  end

  describe "GET /evaluations/:id/submissions" do
    let(:evaluator) { create(:user, role: 'evaluator') }
    let(:challenge) { create(:challenge) }
    let(:phase) { create(:phase, challenge: challenge) }
    let!(:evaluation_form) { create(:evaluation_form, phase: phase, challenge: challenge) }

    context "when logged in as an evaluator" do
      before do
        log_in_user(evaluator)
        ChallengePhasesEvaluator.create!(challenge: challenge, phase: phase, user: evaluator)
      end

      context "with assigned submissions" do
        let!(:submission) { create(:submission, phase: phase) }
        let!(:assignment) do
          create(:evaluator_submission_assignment,
                submission: submission,
                evaluator: evaluator,
                status: :assigned)
        end

        it "displays the submissions page successfully" do
          get submissions_evaluation_path(phase)

          expect(response).to have_http_status(:success)
          expect(response.body).to include("View challenge submissions and manage evaluation progress.")
        end

        it "shows assigned submissions" do
          get submissions_evaluation_path(phase)

          expect(response.body).to include(submission.id.to_s)
        end

        it "shows submission counts" do
          get submissions_evaluation_path(phase)
        end
      end

      context "with no submissions" do
        it "shows empty state message" do
          get submissions_evaluation_path(phase)

          expect(response.body).to include("This challenge phase does not currently have any submissions.")
        end
      end
    end
  end
end
