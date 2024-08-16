require "rails_helper"

RSpec.describe "DashboardController" do
  describe "GET /" do
    before { get "/" }

    it_behaves_like "a page with footer content"
  end

  describe "GET /dashboard" do
    before { get "/dashboard" }

    it_behaves_like "a page with footer content"
  end
end
