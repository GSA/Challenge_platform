require 'rails_helper'

RSpec.describe "EvaluationForms" do
  describe "GET /evaluation_forms" do
    context "when logged in as a super admin" do
      before do
        create_and_log_in_user(role: "super_admin")
      end

      it "redirects to the phoenix app" do
        get evaluation_forms_path

        expect(response).to redirect_to(ENV.fetch("PHOENIX_URI", nil))
      end
    end

    context "when logged in as a admin" do
      before do
        create_and_log_in_user(role: "admin")
      end

      it "redirects to the phoenix app" do
        get evaluation_forms_path

        expect(response).to redirect_to(ENV.fetch("PHOENIX_URI", nil))
      end
    end

    context "when logged in as a challenge manager" do
      let(:user) { create_user(role: "challenge_manager") }

      before { log_in_user(user) }

      it "renders the index view with the correct header" do
        get evaluation_forms_path

        expect(response).to have_http_status(:success)
        expect(response.body).to include("Evaluation Forms")
      end

      it "renders an empty list" do
        get evaluation_forms_path
        expect(response.body).to include("You currently do not have any evaluation forms.")
      end

      it "renders a list of evaluation forms for the current user's challenges" do
        agency = Agency.create!(name: "Gandalf and Sons", acronym: "GAD")
        challenge = Challenge.create!(user:, agency:, title: "Turning red bull into water")
        ChallengeManager.create(user:, challenge:)

        create_evaluation_form(title: "Frodo", challenge_id: challenge.id, challenge_phase: 1)
        create_evaluation_form(title: "Sam", challenge_id: challenge.id, challenge_phase: 2)
        get evaluation_forms_path
        expect(response.body).to include("Sam")
        expect(response.body).to include("Frodo")
      end

      it "does not include evaluation forms for challenges not assigned to the current user" do
        agency = Agency.create!(name: "Gandalf and Sons", acronym: "GAD")
        challenge = Challenge.create!(user:, agency:, title: "Turning monster energy into chamomile")
        ChallengeManager.create(user:, challenge:)

        user2 = create_user(role: "challenge_manager", email: "testwizard@example.gov")
        challenge2 = Challenge.create!(user: user2, agency:, title: "Turning frogs into princes")
        ChallengeManager.create(user: user2, challenge:)

        create_evaluation_form(title: "Shrek", challenge_id: challenge.id, challenge_phase: 1)
        create_evaluation_form(title: "Fiona", challenge_id: challenge.id, challenge_phase: 2)
        create_evaluation_form(title: "Donkey", challenge_id: challenge2.id, challenge_phase: 1)
        create_evaluation_form(title: "Farquad", challenge_id: challenge2.id, challenge_phase: 2)

        get evaluation_forms_path
        expect(response.body).to include("Shrek")
        expect(response.body).to include("Fiona")
        expect(response.body).not_to include("Donkey")
        expect(response.body).not_to include("Farquad")
      end
    end

    context "when logged in as an evaluator" do
      before do
        create_and_log_in_user(role: "evaluator")
      end

      it "redirects to the dashboard" do
        get evaluation_forms_path

        expect(response).to redirect_to(dashboard_path)
      end
    end

    context "when logged in as a solver" do
      before do
        create_and_log_in_user(role: "solver")
      end

      it "redirects to the phoenix app" do
        get evaluation_forms_path

        expect(response).to redirect_to(ENV.fetch("PHOENIX_URI", nil))
      end
    end
  end

  describe "PATCH /evaluation_forms/:id" do
    let(:challenge_user) { create_user(role: "challenge_manager") }
    let(:challenge) { create_challenge(user: challenge_user) }
    let(:evaluation_form) { create_evaluation_form(challenge_id: challenge.id, challenge_phase: 1) }

    before { log_in_user(challenge_user) }

    context "when requiring evaluator comments on scores" do
      it "updates the comments_required attribute" do
        patch evaluation_form_path(evaluation_form), params: { evaluation_form: { comments_required: true } }
        evaluation_form.reload
        expect(evaluation_form.comments_required).to be_truthy
      end
    end

    context "when updating weighted scoring in scale type" do
      it "updates the weighted_scoring attribute" do
        patch evaluation_form_path(evaluation_form), params: { evaluation_form: { weighted_scoring: true } }
        evaluation_form.reload
        expect(evaluation_form.weighted_scoring).to be_truthy
      end
    end
  end
end
