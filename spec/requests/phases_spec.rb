require 'rails_helper'

RSpec.describe "Phases" do
  describe "GET /phases" do
    context "when logged in as a super admin" do
      before do
        create_and_log_in_user(role: "super_admin")
      end

      it "redirects to the phoenix app" do
        get phases_path

        expect(response).to redirect_to(ENV.fetch("PHOENIX_URI", nil))
      end
    end

    context "when logged in as a admin" do
      before do
        create_and_log_in_user(role: "admin")
      end

      it "redirects to the phoenix app" do
        get phases_path

        expect(response).to redirect_to(ENV.fetch("PHOENIX_URI", nil))
      end
    end

    context "when logged in as a challenge manager" do
      let(:challenge_user) { create_user(role: "challenge_manager") }

      before { log_in_user(challenge_user) }
      before { get "/phases" }

      it_behaves_like "a page with footer content"
      it_behaves_like "a page with header content"
      it_behaves_like "a page with utility menu links for all users"
      it_behaves_like "a page with utility menu links for a challenge manager"

      it "renders the index view with the correct content" do
        expect(response).to have_http_status(:success)
        expect(response.body).to include("My Challenges")
        expect(response.body).to include("Resources and support")
      end

      it "renders an empty list" do
        expect(response.body).to include("You currently do not have any challenges.")
      end

      it "renders a list of challenges" do
        challenge = create(:challenge, user: challenge_user, title: "Turning monster energy into pepto bismol")
        phase = create_phase(challenge_id: challenge.id)
        ChallengeManager.create(user: challenge_user, challenge:)
        frodo = create_evaluation_form(title: "Frodo", challenge_id: challenge.id, phase_id: phase.id)

        get phases_path
        expect(response.body).to include("Turning monster energy into pepto bismol")
        expect(response.body).to have_link("Edit form", href: edit_phase_evaluation_form_path(phase, frodo))
      end
    end

    context "when logged in as an evaluator" do
      before do
        create_and_log_in_user(role: "evaluator", status: "active")
      end

      it "redirects to the evaluator landing page" do
        get phases_path

        expect(response).to redirect_to(evaluations_path)
      end
    end

    context "when logged in as a solver" do
      before do
        create_and_log_in_user(role: "solver")
      end

      it "redirects to the phoenix app" do
        get phases_path

        expect(response).to redirect_to(ENV.fetch("PHOENIX_URI", nil))
      end
    end
  end
end
