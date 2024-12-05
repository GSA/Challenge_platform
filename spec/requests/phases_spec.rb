require 'rails_helper'

RSpec.describe "Phases" do
  describe "GET /phases" do
    context "when logged in as a super admin" do
      before do
        create_and_log_in_user(role: "super_admin")
      end

      it "redirects to the phoenix app" do
        get phases_path

        expect(response).to redirect_to(ENV.fetch("PHOENIX_URI", nil))
      end
    end

    context "when logged in as a admin" do
      before do
        create_and_log_in_user(role: "admin")
      end

      it "redirects to the phoenix app" do
        get phases_path

        expect(response).to redirect_to(ENV.fetch("PHOENIX_URI", nil))
      end
    end

    context "when logged in as a challenge manager" do
      let(:challenge_user) { create_user(role: "challenge_manager") }

      before { log_in_user(challenge_user) }

      it "renders the index view with the correct header" do
        get phases_path

        expect(response).to have_http_status(:success)
        expect(response.body).to include("Submissions & Evaluations")
        expect(response.body).to include("View challenge submissions")
      end

      it "renders an empty list" do
        get phases_path

        expect(response.body).to include("You currently do not have any challenges.")
      end

      it "renders a list of challenges" do
        challenge = create(:challenge, user: challenge_user, title: "Turning monster energy into pepto bismol")
        phase = create_phase(challenge_id: challenge.id)
        ChallengeManager.create(user: challenge_user, challenge:)
        create_evaluation_form(title: "Frodo", challenge_id: challenge.id, phase_id: phase.id)

        get phases_path
        expect(response.body).to include("Turning monster energy into pepto bismol")
        expect(response.body).to include("Frodo")
      end
    end

    context "when logged in as an evaluator" do
      before do
        create_and_log_in_user(role: "evaluator")
      end

      it "redirects to the dashboard" do
        get phases_path

        expect(response).to redirect_to(dashboard_path)
      end
    end

    context "when logged in as a solver" do
      before do
        create_and_log_in_user(role: "solver")
      end

      it "redirects to the phoenix app" do
        get phases_path

        expect(response).to redirect_to(ENV.fetch("PHOENIX_URI", nil))
      end
    end
  end

  describe 'GET /phases/:id/submissions' do
    let(:challenge_user) { create_user(role: "challenge_manager") }
    let(:challenge) { create(:challenge, user: challenge_user) }
    let(:phase) { create(:phase, challenge: challenge) }
    let!(:submission1) { create(:submission, challenge: challenge, phase: phase, status: 'submitted') }
    let!(:submission2) { create(:submission, challenge: challenge, phase: phase, status: 'submitted') }
    let!(:submission3) { create(:submission, challenge: challenge, phase: phase, status: 'submitted', judging_status: 'selected') }
    let!(:submission4) { create(:submission, challenge: challenge, phase: phase, status: 'submitted', judging_status: 'winner') }

    before { log_in_user(challenge_user) }

    it 'assigns submissions and calculates status counts' do
      get submissions_phase_path(phase)

      expect(assigns(:submissions)).to match_array([submission1, submission2, submission3, submission4])
      expect(assigns(:not_started)).to match_array([submission1, submission2, submission3, submission4])
      expect(assigns(:in_progress)).to be_empty
      expect(assigns(:completed)).to be_empty
      expect(assigns(:submissions_by_status)).to eq({
        not_started: 4,
        in_progress: 0,
        completed: 0
      })
    end

    context 'when filtering by status' do
      let(:assignment1) { create(:evaluator_submission_assignment, submission: submission1) }
      let(:assignment2) { create(:evaluator_submission_assignment, submission: submission2) }

      before(:each) do
        # Create evaluations
        create(:evaluation, evaluator_submission_assignment: assignment1, completed_at: Time.current)
        create(:evaluation, evaluator_submission_assignment: assignment2, completed_at: nil)

        # Ensure assignment2 is NOT recused
        assignment2.update!(status: :assigned)
        # Explicitly set assignment1 as recused
        assignment1.update!(status: :recused)
      end

      it 'filters not_started submissions' do
        get submissions_phase_path(phase), params: { status: 'not_started' }
        expect(assigns(:submissions)).to match_array([submission3, submission4])
      end

      it 'filters in_progress submissions' do
        get submissions_phase_path(phase), params: { status: 'in_progress' }
        expect(assigns(:submissions)).to match_array([submission2])
      end

      it 'filters completed submissions' do
        get submissions_phase_path(phase), params: { status: 'completed' }
        expect(assigns(:submissions)).to match_array([submission1])
      end

      it 'filters recused submissions' do
        expect(assignment1.reload.status).to eq('recused')
        expect(assignment2.reload.status).to eq('assigned')

        get submissions_phase_path(phase), params: { status: 'recused' }
        expect(assigns(:submissions)).to match_array([submission1])
      end
    end

    context 'when filtering by eligibility' do
      it 'filters eligible for evaluation submissions' do
        get submissions_phase_path(phase), params: { eligible_for_evaluation: 'true' }
        expect(assigns(:submissions)).to match_array([submission3, submission4])
      end

      it 'filters selected to advance submissions' do
        get submissions_phase_path(phase), params: { selected_to_advance: 'true' }
        expect(assigns(:submissions)).to match_array([submission4])
      end
    end

    context 'when sorting submissions' do
      let(:assignment1) { create(:evaluator_submission_assignment, submission: submission1) }
      let(:assignment2) { create(:evaluator_submission_assignment, submission: submission2) }

      before(:each) do
        create(:evaluation, evaluator_submission_assignment: assignment1, total_score: 90)
        create(:evaluation, evaluator_submission_assignment: assignment2, total_score: 85)
      end

      it 'sorts by average score high to low' do
        get submissions_phase_path(phase), params: { sort: 'average_score_high_to_low' }
        expect(assigns(:submissions).to_a).to eq([submission4, submission3, submission2, submission1])
      end

      it 'sorts by average score low to high' do
        get submissions_phase_path(phase), params: { sort: 'average_score_low_to_high' }
        expect(assigns(:submissions).to_a).to eq([submission1, submission2, submission3, submission4])
      end

      it 'sorts by submission id high to low' do
        get submissions_phase_path(phase), params: { sort: 'submission_id_high_to_low' }
        expect(assigns(:submissions).to_a).to eq([submission4, submission3, submission2, submission1])
      end

      it 'sorts by submission id low to high' do
        get submissions_phase_path(phase), params: { sort: 'submission_id_low_to_high' }
        expect(assigns(:submissions).to_a).to eq([submission1, submission2, submission3, submission4])
      end
    end
  end
end
