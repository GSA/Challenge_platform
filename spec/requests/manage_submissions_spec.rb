require 'rails_helper'

RSpec.describe "ManageSubmissions", type: :request do
  describe "GET /manage_submissions" do
    it "renders the index view with the correct header" do
      get manage_submissions_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Manage Submissions")
    end
  end
end
