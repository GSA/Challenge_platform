# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Solver Dashboard", type: :request do
  let(:user) { create(:user, role: 'solver') }
  let(:challenge) { create(:challenge) }
  let(:phase) { create(:phase, challenge: challenge) }
  let!(:submission) { create(:submission, phase: phase, submitter: user) }

  before do
    log_in_user(user)
    get "/solver/dashboard"
  end

  it_behaves_like "a page with footer content"
  it_behaves_like "a page with header content"
  it_behaves_like "a page with utility menu links for all users"
  it_behaves_like "a page with utility menu links for a solver"

  describe "GET /solver/dashboard" do
    it "renders the dashboard with the correct content" do
      get "/solver/dashboard"

      expect(response).to have_http_status(:success)
      expect(response.body).to have_css('h1', text: 'Dashboard')
      expect(response.body).to have_css('h2', text: 'My submissions')
      expect(response.body).to have_css('h2', text: 'My saved challenges')
      expect(response.body).to have_css('h2', text: 'Resources')
    end
  end
end