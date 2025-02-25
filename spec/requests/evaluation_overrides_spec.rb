require 'rails_helper'

RSpec.describe "EvaluationOverrides" do
  describe "GET /evaluations/:id/revision #show" do
    context "as a challenge_manager" do
      before do
        create_and_log_in_user(role: "challenge_manager")
      end

      context "with an associated and complete evaluation" do
        it "renders the blank override form" do
        end
      end

      context "that has already revised the evaluation" do
        it "renders the override form with data that was filled" do
        end
      end

      context "trying to view a non-associated evaluation" do
        it "redirects to the submission path with an alert" do
        end
      end

      context "trying to view a non-complete evaluation" do
        it "redirects to the submission path with an alert" do
        end
      end
    end

    context "as an evaluator" do
      it "redirects to the dashboard path with an alert" do
      end
    end
  end

  describe "PATCH /evaluations/:id/revision #update" do
    context "" do
      it "" do
      end
    end
  end
end
