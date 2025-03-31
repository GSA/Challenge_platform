require "rails_helper"

RSpec.describe "SubmissionMaterialsController" do
  describe "/submissions/:id/materials"
  let(:user) { nil }
  let(:challenge) { create(:challenge, user: user, title: "Boston Tea Party Cleanup") }
  let(:phase) { create(:phase, challenge: challenge) }
  let(:submission) { create(:submission, challenge: challenge, phase: phase) }

  context "when logged in as a super admin" do
    let(:user) do
      create_and_log_in_user(role: "super_admin")
    end

    it "redirects to the phoenix app" do
      get materials_submission_path(submission)

      expect(response).to redirect_to(ENV.fetch("PHOENIX_URI", nil))
    end
  end

  context "when logged in as a admin" do
    let(:user) do
      create_and_log_in_user(role: "admin")
    end

    it "redirects to the phoenix app" do
      get materials_submission_path(submission)

      expect(response).to redirect_to(ENV.fetch("PHOENIX_URI", nil))
    end
  end

  context "when logged in as a challenge manager" do
    let(:user) { create_user(role: "challenge_manager") }

    before { log_in_user(user) }

    it "renders the submission view with the correct header" do
      get materials_submission_path(submission)

      expect(response).to have_http_status(:success)
      expect(response.body).to have_css("h2", text: "Submission ID #{submission.id}")
      expect(response.body).to have_css("h3", text: "Brief Description:")
    end
  end

  context "when logged in as an evaluator" do
    let(:user) do
      create_and_log_in_user(role: "evaluator", status: "active")
    end

    context "with a gov email" do
      before do
        user.update(email: generate_user_email(type: :gov))
      end

      it "does not show submission when evaluator is not assigned" do
        get materials_submission_path(submission)
        expect(response).to have_http_status(:not_found)
      end

      it "renders the submission view when assigned" do
        create(
          :evaluator_submission_assignment,
          submission: submission,
          evaluator: user,
          status: :assigned
        )
        get materials_submission_path(submission)

        expect(response).to have_http_status(:success)
        expect(response.body).to have_css("h2", text: "Submission ID #{submission.id}")
        expect(response.body).to have_css("h3", text: "Brief Description:")
      end
    end

    context "with a non gov email" do
      before do
        user.update(email: generate_user_email(type: :non_gov))
      end

      it "does not show submission when evaluator is not assigned" do
        get materials_submission_path(submission)

        expect(response).to have_http_status(:redirect)
      end

      it "redirects away from submission view" do
        create(
          :evaluator_submission_assignment,
          submission: submission,
          evaluator: user,
          status: :assigned
        )
        get materials_submission_path(submission)

        expect(response).to have_http_status(:redirect)
      end
    end
  end

  context "when logged in as a solver" do
    let(:user) do
      create_and_log_in_user(role: "solver")
    end

    it "redirects to the phoenix app" do
      get materials_submission_path(submission)

      expect(response).to redirect_to(ENV.fetch("PHOENIX_URI", nil))
    end
  end
end
