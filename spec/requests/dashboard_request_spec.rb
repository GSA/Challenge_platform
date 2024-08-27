require "rails_helper"

RSpec.describe "DashboardController" do
  describe "GET /" do
    before { get "/" }

    it_behaves_like "a page with footer content"

    it_behaves_like "a page with header content"

    # binding.pry

    it_behaves_like "a page with utility menu links for a public solver"
    it_behaves_like "a page with utility menu links for a challenge manager"
    it_behaves_like "a page with utility menu links for an evaluator"
  end

  describe "GET /dashboard" do
    before { get "/dashboard" }

    it_behaves_like "a page with footer content"
  end
end
