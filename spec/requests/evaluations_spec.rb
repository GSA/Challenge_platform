require 'rails_helper'

RSpec.describe "Evaluations" do
  describe "GET /index" do
    it "returns http success" do
      get "/evaluations"
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Evaluations")
    end
  end
end
