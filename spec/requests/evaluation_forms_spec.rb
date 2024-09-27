require 'rails_helper'

RSpec.describe "EvaluationForms" do
  let(:user) { create_user(role: "challenge_manager") }

  context "when a challenge_manager is logged in" do
    before { log_in_user(user) }

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

      it "renders a list of evaluation forms for the current user's challenges" do
        agency = Agency.create!(name: "Gandalf and Sons", acronym: "GAD")
        challenge = Challenge.create!(user:, agency:, title: "Turning red bull into water")
        ChallengeManager.create(user:, challenge:)

        EvaluationForm.create!(title: "Frodo", challenge_id: challenge.id)
        EvaluationForm.create!(title: "Sam", challenge_id: challenge.id)
        get evaluation_forms_path
        expect(response.body).to include("Sam")
        expect(response.body).to include("Frodo")
      end

      it "does not include evaluation forms for challenges not assigned to the current user" do
        agency = Agency.create!(name: "Gandalf and Sons", acronym: "GAD")
        challenge = Challenge.create!(user:, agency:, title: "Turning monster energy into chamomile")
        ChallengeManager.create(user:, challenge:)

        user2 = create_user(role: "challenge_manager", email: "testwizard@example.gov")
        challenge2 = Challenge.create!(user: user2, agency:, title: "Turning frogs into princes")
        ChallengeManager.create(user: user2, challenge:)

        EvaluationForm.create!(title: "Shrek", challenge_id: challenge.id)
        EvaluationForm.create!(title: "Fiona", challenge_id: challenge.id)
        EvaluationForm.create!(title: "Donkey", challenge_id: challenge2.id)
        EvaluationForm.create!(title: "Farquad", challenge_id: challenge2.id)

        get evaluation_forms_path
        expect(response.body).to include("Shrek")
        expect(response.body).to include("Fiona")
        expect(response.body).not_to include("Donkey")
        expect(response.body).not_to include("Farquad")
      end
    end
  end
end
