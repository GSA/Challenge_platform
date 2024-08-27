require "rails_helper"

RSpec.describe "DashboardController" do
  describe "GET /" do
    let(:user) { create_and_log_in_user }
    before { get "/" }

    it_behaves_like "a page with footer content"

    context "public solver" do
      before { 
        user.update(role: "solver")  
        get "/"
      } 

      it_behaves_like "a page with utility menu links for a public solver"
    end  


    context "challenge manager" do
      before { 
        user.update(role: "challenge_manager")  
        get "/"
      } 

      it_behaves_like "a page with utility menu links for a challenge manager"
    end

    context "challenge manager" do
      before { 
        user.update(role: "evaluator")  
        get "/"
      } 

      it_behaves_like "a page with utility menu links for an evaluator"
    end
  end

  describe "GET /dashboard" do
    before { get "/dashboard" }

    it_behaves_like "a page with footer content"
  end
end
