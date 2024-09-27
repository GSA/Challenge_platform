require 'rails_helper'

RSpec.describe "EvaluationForms" do
  before { create_and_log_in_user(role: "challenge_manager") }

  describe "GET /evaluation_forms" do
    it "renders the index view with the correct header" do
      get evaluation_forms_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Evaluation Forms")
    end

    it "renders an empty list" do
      get evaluation_forms_path
      expect(response.body).to include("You currently do not have any evaluation forms.")
    end
    
    it "renders a list of evaluation forms" do
      EvaluationForm.create!(title: "Frodo")
      EvaluationForm.create!(title: "Sam")
      get evaluation_forms_path
      expect(response.body).to include("Frodo")
      expect(response.body).to include("Sam")
    end  
  end
end
