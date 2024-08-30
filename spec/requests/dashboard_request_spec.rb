require "rails_helper"

RSpec.describe "DashboardController" do
  let(:user) { create_and_log_in_user }

  describe "GET /" do
    before { get "/" }

    it_behaves_like "a page with footer content"
    it_behaves_like "a page with header content"

    context "when logged in as public solver on the root url" do
      before do
        user.update(role: "solver")
        get "/"
      end

      it_behaves_like "a page with utility menu links for all users"
      it_behaves_like "a page with utility menu links for a public solver"
    end

    context "when logged in as a challenge manager on the root url" do
      before do
        user.update(role: "challenge_manager")
        get "/"
      end

      it_behaves_like "a page with utility menu links for all users"
      it_behaves_like "a page with utility menu links for a challenge manager"
      it_behaves_like "a page with dashboard content for a challenge manager"
    end

    context "when logged in as an evaluator on the root url" do
      before do
        user.update(role: "evaluator")
        get "/"
      end

      it_behaves_like "a page with utility menu links for all users"
      it_behaves_like "a page with utility menu links for an evaluator"
    end
  end

  describe "GET /dashboard" do
    before { get "/dashboard" }

    it_behaves_like "a page with footer content"
    it_behaves_like "a page with header content"

    context "when logged in as a public solver on the dashboard" do
      before do
        user.update(role: "solver")
        get "/dashboard"
      end

      it_behaves_like "a page with utility menu links for all users"
      it_behaves_like "a page with utility menu links for a public solver"
    end

    context "when logged in as a challenge manager on the dashboard" do
      before do
        user.update(role: "challenge_manager")
        get "/dashboard"
      end

      it_behaves_like "a page with utility menu links for all users"
      it_behaves_like "a page with utility menu links for a challenge manager"
      it_behaves_like "a page with dashboard content for a challenge manager"
    end

    context "when logged in as an evaluator on the dashboard" do
      before do
        user.update(role: "evaluator")
        get "/dashboard"
      end

      it_behaves_like "a page with utility menu links for all users"
      it_behaves_like "a page with utility menu links for an evaluator"
    end
  end
end
