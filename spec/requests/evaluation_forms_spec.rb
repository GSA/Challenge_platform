require 'rails_helper'

RSpec.describe "EvaluationForms" do
  describe "GET /evaluation_forms" do
    context "when logged in as a challenge manager" do
      before do
        create_and_log_in_user(role: "challenge_manager")
      end

      it "renders the index view with the correct header" do
        get evaluation_forms_path

        expect(response).to have_http_status(:success)
        expect(response.body).to include("Evaluation Forms")
      end
    end

    context "when logged in as an evaluator" do
      before do
        create_and_log_in_user(role: "evaluator")
      end

      it "renders the index view with the correct header" do
        get evaluation_forms_path

        expect(response).to redirect_to(dashboard_path)
      end
    end

    context "when logged in as a solver" do
      before do
        create_and_log_in_user(role: "solver")
      end

      it "renders the index view with the correct header" do
        get evaluation_forms_path

        expect(response).to redirect_to(ENV.fetch("PHOENIX_URI", nil))
      end
    end
  end
end
