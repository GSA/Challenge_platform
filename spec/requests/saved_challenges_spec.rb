require 'rails_helper'

RSpec.describe "SavedChallenges", type: :request do
  let(:solver) { create_user(role: "solver") }

  describe "GET /index" do
    let(:open_challenge) { create(:published_challenge, sub_status: 'open') }
    let(:open_soon_challenge) { create(:published_challenge, sub_status: nil) }
    let(:closed_challenge) { create(:published_challenge, sub_status: 'closed') }

    context "when logged in as a solver" do
      before do
        log_in_user(solver)
        get saved_challenges_path
      end

      it_behaves_like "a page with footer content"
      it_behaves_like "a page with header content"
      it_behaves_like "a page with utility menu links for all users"
      it_behaves_like "a page with utility menu links for a solver"

      context "when the user has no saved challenges" do
        it "renders an empty list" do
          get saved_challenges_path
          expect(solver.challenges_saved).to be_empty
          expect(response).to have_http_status(:success)
          expect(response.body).to have_css('p', text: "You have no saved challenges.")
        end
      end

      context "when the user has saved open challenges", bullet: :dont_raise do
        before { solver.challenges_saved << open_challenge }

        it "renders the index view with the correct content" do
          get saved_challenges_path
          expect(response).to have_http_status(:success)
          expect(response.body).to have_css('h2', text: 'Open for submissions (1)')
          expect(response.body).to have_css('h3', text: open_challenge.title)
        end
      end

      context "when the user has saved challenges that are opening soon", bullet: :dont_raise do
        before { solver.challenges_saved << open_soon_challenge }

        it "renders the index view with the correct content" do
          get saved_challenges_path
          expect(response).to have_http_status(:success)
          expect(response.body).to have_css('h2', text: 'Opening soon (1)')
          expect(response.body).to have_css('h3', text: open_soon_challenge.title)
        end
      end

      context "when the user has saved closed challenges", bullet: :dont_raise do
        before { solver.challenges_saved << closed_challenge }

        it "renders the index view with the correct content" do
          get saved_challenges_path
          expect(response).to have_http_status(:success)
          expect(response.body).to have_css('h2', text: 'Closed to submissions')
          expect(response.body).to have_css('h3', text: closed_challenge.title)
        end
      end
    end
  end

  describe "POST /create" do
    let(:challenge) { create(:published_challenge) }

    context "when logged in as a solver", bullet: :dont_raise do
      before do
        log_in_user(solver)
        post saved_challenges_path, params: { challenge_id: challenge.id }
      end

      it "saves the challenge successfully" do
        expect(solver.challenges_saved).to include(challenge)
        expect(response).to redirect_to(saved_challenges_path)
        follow_redirect!
        expect(response.body).to have_css('p', text: "Challenge saved successfully")
      end
    end
  end

  describe "DELETE /destroy" do
    let(:challenge) { create(:published_challenge) }

    context "when logged in as a solver" do
      before do
        log_in_user(solver)
        solver.challenges_saved << challenge
        delete saved_challenge_path(challenge.id)
      end

      it "removes the challenge successfully" do
        expect(solver.challenges_saved).not_to include(challenge)
        expect(response).to redirect_to(saved_challenges_path)
        follow_redirect!
        expect(response.body).to have_css('p', text: "Challenge removed successfully")
      end
    end
  end
end
