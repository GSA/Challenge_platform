require 'rails_helper'

RSpec.describe "EvaluationForms" do
  before { create_and_log_in_user(role: "challenge_manager") }

  describe "GET /evaluation_forms" do
    it "renders the index view with the correct header" do
      get evaluation_forms_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Evaluation Forms")
    end
  end
end
