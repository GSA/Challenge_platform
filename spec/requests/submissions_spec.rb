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

        expect(response.body).to include("No submissions found.")
      end

      it "renders a list of submissions for a user's challenge" do
        submission = create(:submission, challenge: challenge, phase: phase)

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

  describe 'GET /phases/:id/submissions' do
    let(:user) { create_user(role: "challenge_manager") }
    let(:challenge) { create(:challenge, user: user) }
    let(:phase) { create(:phase, challenge: challenge) }

    before do
      ChallengeManager.create!(user: user, challenge: challenge)
      log_in_user(user)
    end

    context 'when viewing submissions' do
      let!(:not_started_submission) { create(:submission, challenge: challenge, phase: phase) }
      let!(:in_progress_submission) do
        submission = create(:submission, challenge: challenge, phase: phase)
        assignment = create(:evaluator_submission_assignment, submission: submission, status: :assigned)
        create(:evaluation, evaluator_submission_assignment: assignment, completed_at: nil)
        submission
      end
      let!(:completed_submission) do
        submission = create(:submission, challenge: challenge, phase: phase)
        assignment = create(:evaluator_submission_assignment, submission: submission)
        create(:evaluation, evaluator_submission_assignment: assignment, completed_at: Time.current)
        submission
      end
      let!(:eligible_submission) { create(:submission, challenge: challenge, phase: phase, judging_status: 'selected') }
      let!(:selected_submission) do
        submission = create(:submission, challenge: challenge, phase: phase, judging_status: 'winner')
        assignment = create(:evaluator_submission_assignment, submission: submission)
        create(:evaluation, evaluator_submission_assignment: assignment, completed_at: Time.current)
        submission
      end

      it 'displays all submissions and their status counts' do
        get submissions_phase_path(phase)

        [not_started_submission, in_progress_submission, completed_submission,
         eligible_submission, selected_submission].each do |submission|
          expect(response.body).to have_css("[data-submission-id='#{submission.id}']")
        end

        expect(response.body).to have_css('.text-secondary-dark.text-bold', text: '2')  # not_started, eligible
        expect(response.body).to have_css('.text-orange.text-bold', text: '1')          # in_progress
        expect(response.body).to have_css('.text-green.text-bold', text: '2')           # completed, selected
      end

      context 'when filtering submissions' do
        it 'shows only submissions matching the selected status' do
          get submissions_phase_path(phase), params: { status: 'not_started' }

          expect(response.body).to have_css("[data-submission-id='#{not_started_submission.id}']")
          expect(response.body).to have_css("[data-submission-id='#{eligible_submission.id}']")
          expect(response.body).not_to have_css("[data-submission-id='#{selected_submission.id}']")
          expect(response.body).not_to have_css("[data-submission-id='#{in_progress_submission.id}']")
          expect(response.body).not_to have_css("[data-submission-id='#{completed_submission.id}']")
        end

        it 'shows only completed submissions' do
          get submissions_phase_path(phase), params: { status: 'completed' }

          expect(response.body).to have_css("[data-submission-id='#{completed_submission.id}']")
          expect(response.body).to have_css("[data-submission-id='#{selected_submission.id}']")
          expect(response.body).not_to have_css("[data-submission-id='#{not_started_submission.id}']")
          expect(response.body).not_to have_css("[data-submission-id='#{in_progress_submission.id}']")
          expect(response.body).not_to have_css("[data-submission-id='#{eligible_submission.id}']")
        end
      end

      context 'when filtering by eligibility' do
        it 'displays only eligible for evaluation submissions' do
          get submissions_phase_path(phase), params: { eligible_for_evaluation: 'true' }

          expect(response.body).to have_css("[data-submission-id='#{eligible_submission.id}']")
          expect(response.body).to have_css("[data-submission-id='#{selected_submission.id}']")
          expect(response.body).not_to have_css("[data-submission-id='#{not_started_submission.id}']")
          expect(response.body).not_to have_css("[data-submission-id='#{in_progress_submission.id}']")
          expect(response.body).not_to have_css("[data-submission-id='#{completed_submission.id}']")
        end

        it 'displays only selected to advance submissions' do
          get submissions_phase_path(phase), params: { selected_to_advance: 'true' }

          expect(response.body).to have_css("[data-submission-id='#{selected_submission.id}']")
          expect(response.body).not_to have_css("[data-submission-id='#{eligible_submission.id}']")
          expect(response.body).not_to have_css("[data-submission-id='#{not_started_submission.id}']")
          expect(response.body).not_to have_css("[data-submission-id='#{in_progress_submission.id}']")
          expect(response.body).not_to have_css("[data-submission-id='#{completed_submission.id}']")
        end
      end

      context 'when sorting submissions' do
        before do
          create(:evaluation,
            evaluator_submission_assignment: create(:evaluator_submission_assignment, submission: in_progress_submission),
            total_score: 80
          )

          create(:evaluation,
            evaluator_submission_assignment: create(:evaluator_submission_assignment, submission: completed_submission),
            total_score: 90
          )
        end

        it 'orders submissions by score high to low' do
          get submissions_phase_path(phase), params: { sort: 'average_score_high_to_low' }

          expect(response.body).to have_selector(
            "tr[data-submission-id='#{completed_submission.id}']" \
            " ~ tr[data-submission-id='#{in_progress_submission.id}']"
          )
        end

        it 'orders submissions by score low to high' do
          get submissions_phase_path(phase), params: { sort: 'average_score_low_to_high' }

          expect(response.body).to have_selector(
            "tr[data-submission-id='#{in_progress_submission.id}']" \
            " ~ tr[data-submission-id='#{completed_submission.id}']"
          )
        end
      end
    end

    context 'when paginating submissions' do
      let!(:submissions) do
        (1..25).map do |n|
          create(:submission, challenge: challenge, phase: phase)
        end
      end

      it 'returns first page of submissions' do
        get submissions_phase_path(phase)
        expect(response.body).to have_css('tr[data-submission-id]', count: 20)
        expect(response.body).to have_button('Load more')
      end

      it 'returns next page of submissions via partial' do
        get submissions_phase_path(phase, page: 2, partial: true)
        expect(response).to have_http_status(:success)
        expect(response.body).to have_css('tr[data-submission-id]', count: 5)
        expect(response.body).not_to have_button('Load more')
      end

      context 'when sorting by average score' do
        let!(:scored_submissions) do
          submissions[0..24].each_with_index do |submission, index|
            create(:evaluation,
              evaluator_submission_assignment: create(:evaluator_submission_assignment, submission: submission),
              total_score: (index + 1) * 20
            )
          end
        end

        it 'paginates correctly when sorted by score' do
          get submissions_phase_path(phase, page: 1, sort: 'average_score_high_to_low')
          expect(response).to have_http_status(:success)
          first_page_scores = response.body.scan(/data-score="(\d+)"/).flatten
          expect(first_page_scores.count).to eq(20)
          expect(first_page_scores.map(&:to_i)).to eq(first_page_scores.map(&:to_i).sort.reverse)
          expect(response.body).to have_button('Load more')

          get submissions_phase_path(phase, page: 2, partial: true, sort: 'average_score_high_to_low')
          expect(response).to have_http_status(:success)
          second_page_scores = response.body.scan(/data-score="(\d+)"/).flatten
          expect(second_page_scores.count).to eq(5)
          expect(second_page_scores.map(&:to_i)).to eq(second_page_scores.map(&:to_i).sort.reverse)
        end
      end

      context 'when filtering submissions' do
        let!(:eligible_submissions) do
          submissions[0..22].each { |s| s.update!(judging_status: 'selected') }
        end

        it 'paginates correctly with eligible filter' do
          get submissions_phase_path(phase, page: 1, eligible_for_evaluation: 'true')
          expect(response).to have_http_status(:success)
          expect(response.body.scan(/data-submission-id="(\d+)"/).flatten.count).to eq(20)
          expect(response.body).to have_button('Load more')

          get submissions_phase_path(phase, page: 2, partial: true, eligible_for_evaluation: 'true')
          expect(response).to have_http_status(:success)
          expect(response.body.scan(/data-submission-id="(\d+)"/).flatten.count).to eq(3)
        end
      end
    end
  end
end
