require 'rails_helper'

RSpec.describe "Submissions" do
  let(:user) { nil }
  let(:challenge) { create_challenge(user: user, title: "Boston Tea Party Cleanup") }
  let(:phase) { create_phase(challenge_id: challenge.id) }

  before { log_in_user(user) }

  describe "GET /phases/:id/submissions" do
    context "when logged in as a super admin" do
      let(:user) { create_user(role: "super_admin") }

      it "redirects to the phoenix app" do
        get phases_path

        expect(response).to redirect_to(ENV.fetch("PHOENIX_URI", nil))
      end
    end

    context "when logged in as a admin" do
      let(:user) { create_user(role: "admin") }

      it "redirects to the phoenix app" do
        get phases_path

        expect(response).to redirect_to(ENV.fetch("PHOENIX_URI", nil))
      end
    end

    context "when logged in as a challenge manager" do
      let(:user) { create_user(role: "challenge_manager") }

      it "renders an empty list of submissions for a user's challenge" do
        get submissions_phase_path(phase)
        expect(response.body).to include("Boston Tea Party Cleanup")

        expect(response.body).to include("This challenge phase does not currently have any submissions.")
      end

      it "renders a list of submissions for a user's challenge" do
        submission = create(:submission, challenge: challenge, phase: phase)
        evaluator = create(:user, role: 'evaluator')
        create(:evaluator_submission_assignment,
               submission: submission,
               evaluator: evaluator,
               status: :assigned,
               evaluation: create(:evaluation))

        get submissions_phase_path(phase)
        expect(response.body).to include("Boston Tea Party Cleanup")
        expect(response.body).to include(submission.id.to_s)
      end

      it "does not render submissions for a challenge the user is not assigned to" do
        challenge = create_challenge(title: "Star Spangled Banister")
        phase = create_phase(challenge_id: challenge.id)

        get submissions_phase_path(phase)
        expect(response).to have_http_status(:not_found)
      end

      it "renders submission statistics" do
        create(:submission, challenge: challenge, phase: phase)
        create(:submission, challenge: challenge, phase: phase, judging_status: "selected")

        allow_any_instance_of(ActionView::Base).to receive(:render).and_call_original
        allow_any_instance_of(ActionView::Base).to receive(:render).
          with(hash_including(partial: "submissions_table")).
          and_return("")

        get submissions_phase_path(phase)
        expect(response.body).to include("Boston Tea Party Cleanup")
        # total submission count
        expect(response.body).to have_css("h3.text-primary", text: "Total Submissions")
        expect(response.body).to have_css("span.font-sans-3xl.text-primary.text-bold", text: "2")
        # selected to advance
        expect(response.body).to have_css("span.text-primary", text: "1 of 2")
      end
    end

    context "when logged in as an evaluator" do
      let(:user) { create_user(role: "evaluator") }

      it "redirects to the dashboard" do
        get submissions_phase_path(phase)

        expect(response).to redirect_to(dashboard_path)
      end
    end

    context "when logged in as a solver" do
      let(:user) { create_user(role: "solver") }

      it "redirects to the phoenix app" do
        get submissions_phase_path(phase)

        expect(response).to redirect_to(ENV.fetch("PHOENIX_URI", nil))
      end
    end
  end

  describe "GET /submissions/:id" do
    context "when logged in as a challenge manager" do
      let(:user) { create_user(role: "challenge_manager") }

      it "renders a details page for an individual submission" do
        submission = create(:submission, challenge: phase.challenge, brief_description: "This submission has legs.")

        get submission_path(submission)
        expect(response.body).to include(submission.id.to_s)
        expect(response.body).to include(submission.brief_description)
      end

      it "does not render submission details for a challenge the user is not assigned to" do
        challenge = create_challenge
        phase = create_phase(challenge_id: challenge.id)
        submission = create(:submission, challenge: phase.challenge, brief_description: "This submission has teeth.")

        get submission_path(submission)
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "PATCH /submissions/:id" do
    context "when logged in as a challenge manager" do
      let(:user) { create_user(role: "challenge_manager") }
      let(:submission) { create(:submission, challenge: challenge, phase: phase) }
      let(:evaluator) { create(:user, role: 'evaluator') }

      before do
        ChallengeManager.create(user: user, challenge: challenge)
      end

      context "updating judging status" do
        it "updates eligibility status to selected" do
          patch submission_path(submission), params: {
            submission: { judging_status: 'selected' }
          }, as: :json

          expect(response).to have_http_status(:ok)
          expect(submission.reload.judging_status).to eq('selected')
        end

        it "prevents deselecting evaluation eligibility when evaluators are assigned" do
          submission.update!(judging_status: 'selected')
          create(:evaluator_submission_assignment,
                 submission: submission,
                 evaluator: evaluator,
                 status: :assigned)

          patch submission_path(submission), params: {
            submission: { judging_status: 'not_selected' }
          }, as: :json

          expect(response).to have_http_status(:unprocessable_entity)
          expect(submission.reload.judging_status).to eq('selected')
          expect(JSON.parse(response.body)['errors']).to include(
            "judging_status" => ["can't deselect evaluation eligibility when there are evaluators assigned"]
          )
        end

        it "allows advancing to winner when eligible and evaluations complete" do
          submission.update!(judging_status: 'selected')
          create(:evaluator_submission_assignment,
                 submission: submission,
                 evaluator: evaluator,
                 status: :assigned,
                 evaluation: create(:evaluation, completed_at: Time.current))

          patch submission_path(submission), params: {
            submission: { judging_status: 'winner' }
          }, as: :json

          expect(response).to have_http_status(:ok)
          expect(submission.reload.judging_status).to eq('winner')
        end

        it "prevents selected to advance when evaluations are incomplete" do
          submission.update!(judging_status: 'selected')
          create(:evaluator_submission_assignment,
                 submission: submission,
                 evaluator: evaluator,
                 status: :assigned)

          patch submission_path(submission), params: {
            submission: { judging_status: 'winner' }
          }, as: :json

          expect(response).to have_http_status(:unprocessable_entity)
          expect(submission.reload.judging_status).to eq('selected')
          expect(JSON.parse(response.body)['errors']).to include(
            "judging_status" => ["can't be selected to advance if not all evaluations are complete"]
          )
        end
      end

      context "updating comments" do
        it "successfully updates comments" do
          patch submission_path(submission), params: {
            submission: { comments: "Comment about submission here" }
          }, as: :json

          expect(response).to have_http_status(:ok)
          expect(submission.reload.comments).to eq("Comment about submission here")
        end
      end
    end
  end
end
