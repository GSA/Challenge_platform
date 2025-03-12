require 'rails_helper'

RSpec.describe "Submissions" do
  let(:user) { nil }
  let(:challenge) { create(:challenge, user: user, title: "Boston Tea Party Cleanup") }
  let(:phase) { create(:phase, challenge: challenge) }

  before { log_in_user(user) }

  describe "GET /submissions/:id" do
    context "when logged in as a challenge manager" do
      let(:user) { create_user(role: "challenge_manager") }

      it "renders a details page for an individual submission" do
        submission = create(:submission, challenge: phase.challenge, phase: phase, brief_description: "This submission has legs.")

        get submission_path(submission)
        expect(response.body).to include(submission.id.to_s)
        expect(response.body).to include(submission.brief_description)
      end

      it "does not render submission details for a challenge the user is not assigned to" do
        challenge = create(:challenge)
        phase = create(:phase, challenge:)
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

      context "when updating judging status" do
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
          expect(response.parsed_body['errors']).to include(
            "judging_status" => ["must remain eligible for evaluation when evaluators are assigned"]
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
          expect(response.parsed_body['errors']).to include(
            "judging_status" => ["can't be selected to advance until all evaluations are complete"]
          )
        end
      end

      context "when updating comments" do
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

    context "when logged in as an evaluator" do
      let(:user) { create_user(role: "evaluator", status: "active") }

      it "redirects to the landing page" do
        get submissions_phase_path(phase)

        expect(response).to redirect_to(evaluations_path)
      end
    end

    context "when logged in as a solver" do
      let(:user) { create_user(role: "solver") }

      it "redirects to the phoenix app" do
        get submissions_phase_path(phase)

        expect(response).to redirect_to(ENV.fetch("PHOENIX_URI", nil))
      end
    end

    context "when logged in as a challenge manager" do
      let(:user) { create_user(role: "challenge_manager") }

      context "when the challenge manager is not assigned to the challenge phase" do
        it "renders :not_found" do
          challenge = create(:challenge, title: "Star Spangled Banister")
          phase = create(:phase, challenge: challenge)

          get submissions_phase_path(phase)
          expect(response).to have_http_status(:not_found)
        end
      end

      context "when there are no submissions for the challenge phase" do
        it "renders an empty list for the challenge phase" do
          get submissions_phase_path(phase)
          expect(response.body).to include("Boston Tea Party Cleanup")
          expect(response.body).to include("No submissions found.")
        end
      end

      context "when there are submissions for the challenge phase" do
        before do
          ChallengeManager.create!(user: user, challenge: challenge)
        end

        it "renders submission statistics" do
          create(:submission, challenge: challenge, phase: phase)
          create(:submission, challenge: challenge, phase: phase, status: "draft")
          create(:submission, challenge: challenge, phase: phase, judging_status: "selected")

          get submissions_phase_path(phase)
          expect(response.body).to include("Boston Tea Party Cleanup")

          # total submission counts
          expect(response.body).to include("At a glance")
          expect(response.body).to have_css("span.text-bold", text: "2")    # Total Submissions (excluding draft)
          expect(response.body).to have_css("span.text-bold", text: "1")    # Eligible for evaluation (selected)
          expect(response.body).to have_css("span.text-bold", text: "0")    # Selected to advance (winner)

          # Evaluation progress stats
          expect(response.body).to have_css(".bg-green-cool-vivid-60v .font-sans-xl.text-white.text-bold", text: "0") # Completed
          expect(response.body).to have_css(".bg-orange-warm-vivid-50v .font-sans-xl.text-white.text-bold", text: "0") # In Progress
          expect(response.body).to have_css(".bg-red-vivid-60v .font-sans-xl.text-white.text-bold", text: "1") # Not Started
        end
      end

      context 'when viewing submissions' do
        let!(:draft_submission) { create(:submission, challenge: challenge, phase: phase, status: "draft") }
        let!(:not_started_submission) do
          create(:submission, challenge: challenge, phase: phase, judging_status: 'selected')
        end
        let!(:in_progress_submission) do
          submission = create(:submission, challenge: challenge, phase: phase, judging_status: 'selected')
          assignment = create(:evaluator_submission_assignment, submission: submission, status: :assigned)
          create(:evaluation, evaluator_submission_assignment: assignment, submission: submission, completed_at: nil)
          submission
        end

        let!(:completed_submission) do
          submission = create(:submission, challenge: challenge, phase: phase, judging_status: 'selected')
          assignment = create(:evaluator_submission_assignment, submission: submission, status: :assigned)
          create(:evaluation, evaluator_submission_assignment: assignment, submission: submission,
                              completed_at: Time.current)
          submission
        end

        let!(:ineligible_submission) do
          create(:submission, challenge: challenge, phase: phase)
        end
        let!(:eligible_submission) do
          create(:submission, challenge: challenge, phase: phase, judging_status: 'selected')
        end
        let!(:selected_submission) do
          submission = create(:submission, challenge: challenge, phase: phase, judging_status: 'winner')
          assignment = create(:evaluator_submission_assignment, submission: submission, status: :assigned)
          create(:evaluation, evaluator_submission_assignment: assignment, submission: submission,
                              completed_at: Time.current)
          submission
        end

        it 'displays all submissions with status: "submitted" and their status counts' do
          get submissions_phase_path(phase)

          [not_started_submission, in_progress_submission, completed_submission,
           eligible_submission, selected_submission].each do |submission|
            expect(response.body).to have_css("[data-submission-id='#{submission.id}']")
          end
          # except the drafts
          expect(response.body).to have_no_css("[data-submission-id='#{draft_submission.id}']")

          expect(response.body).to have_css('.bg-red-vivid-60v .font-sans-xl.text-white', text: '2') # not_started
          expect(response.body).to have_css('.bg-orange-warm-vivid-50v .font-sans-xl.text-white', text: '1') # in_progress
          expect(response.body).to have_css('.bg-green-cool-vivid-60v .font-sans-xl.text-white', text: '2')  # completed
        end

        context 'when filtering submissions' do
          it 'shows only submissions matching the selected status', bullet: :dont_raise do
            get submissions_phase_path(phase), params: { status: 'not_started' }

            expect(response.body).to have_css("[data-submission-id='#{not_started_submission.id}']")
            expect(response.body).to have_css("[data-submission-id='#{eligible_submission.id}']")
            expect(response.body).to have_no_css("[data-submission-id='#{selected_submission.id}']")
            expect(response.body).to have_no_css("[data-submission-id='#{in_progress_submission.id}']")
            expect(response.body).to have_no_css("[data-submission-id='#{completed_submission.id}']")
          end

          it 'shows only completed submissions', bullet: :dont_raise do
            get submissions_phase_path(phase), params: { status: 'completed' }

            expect(response.body).to have_css("[data-submission-id='#{completed_submission.id}']")
            expect(response.body).to have_css("[data-submission-id='#{selected_submission.id}']")
            expect(response.body).to have_no_css("[data-submission-id='#{not_started_submission.id}']")
            expect(response.body).to have_no_css("[data-submission-id='#{in_progress_submission.id}']")
            expect(response.body).to have_no_css("[data-submission-id='#{eligible_submission.id}']")
          end
        end

        context 'when filtering by eligibility' do
          it 'displays only eligible for evaluation submissions', bullet: :dont_raise do
            get submissions_phase_path(phase), params: { eligible_for_evaluation: 'true' }

            expect(response.body).to have_css("[data-submission-id='#{eligible_submission.id}']")
            expect(response.body).to have_css("[data-submission-id='#{selected_submission.id}']")
            expect(response.body).to have_css("[data-submission-id='#{not_started_submission.id}']")
            expect(response.body).to have_css("[data-submission-id='#{in_progress_submission.id}']")
            expect(response.body).to have_css("[data-submission-id='#{completed_submission.id}']")
            expect(response.body).to have_no_css("[data-submission-id='#{ineligible_submission.id}']")
          end

          it 'displays only selected to advance submissions', bullet: :dont_raise do
            get submissions_phase_path(phase), params: { selected_to_advance: 'true' }

            expect(response.body).to have_css("[data-submission-id='#{selected_submission.id}']")
            expect(response.body).to have_no_css("[data-submission-id='#{eligible_submission.id}']")
            expect(response.body).to have_no_css("[data-submission-id='#{not_started_submission.id}']")
            expect(response.body).to have_no_css("[data-submission-id='#{in_progress_submission.id}']")
            expect(response.body).to have_no_css("[data-submission-id='#{completed_submission.id}']")
          end
        end

        context 'when sorting submissions' do
          before do
            assignments = create_list(:evaluator_submission_assignment, 3,
              submission: completed_submission,
              status: :assigned
            )

            assignments.each do |assignment|
              create(:evaluation,
                     evaluator_submission_assignment: assignment,
                     submission: completed_submission,
                     completed_at: Time.current,
                     total_score: 90)
            end

            create(:evaluator_submission_assignment,
              submission: completed_submission,
              status: :recused
            )

            EvaluationStatusService.update_evaluation_status(completed_submission)

            create(:evaluation,
                   evaluator_submission_assignment: create(:evaluator_submission_assignment,
                                                           submission: in_progress_submission),
                   total_score: 80)

            create_list(:evaluator_submission_assignment, 2,
              submission: not_started_submission,
              status: :assigned
            )
            create(:evaluator_submission_assignment,
              submission: not_started_submission,
              status: :recused
            )
          end

          it 'orders submissions by assigned evaluators high to low' do
            get submissions_phase_path(phase), params: { sort: 'assignees_high_to_low' }

            # completed_submission: 6 evaluators (4 assigned + 2 recused)
            # not_started_submission: 3 evaluators (2 assigned + 1 recused)
            # in_progress_submission: 2 evaluator (2 assigned)
            # eligible_submission: 0 evaluators
            expect(response.body).to have_css(
              "tr[data-submission-id='#{completed_submission.id}'] ~ tr[data-submission-id='#{not_started_submission.id}']"
            )
            expect(response.body).to have_css(
              "tr[data-submission-id='#{not_started_submission.id}'] ~ tr[data-submission-id='#{in_progress_submission.id}']"
            )
            expect(response.body).to have_css(
              "tr[data-submission-id='#{in_progress_submission.id}'] ~ tr[data-submission-id='#{eligible_submission.id}']"
            )
          end

          it 'orders submissions by assigned evaluators low to high' do
            get submissions_phase_path(phase), params: { sort: 'assignees_low_to_high' }

            # eligible_submission: 0 evaluators
            # in_progress_submission: 2 evaluator (2 assigned)
            # not_started_submission: 3 evaluators (2 assigned + 1 recused)
            # completed_submission: 6 evaluators (4 assigned + 2 recused)
            expect(response.body).to have_css(
              "tr[data-submission-id='#{eligible_submission.id}'] ~ tr[data-submission-id='#{in_progress_submission.id}']"
            )
            expect(response.body).to have_css(
              "tr[data-submission-id='#{in_progress_submission.id}'] ~ tr[data-submission-id='#{not_started_submission.id}']"
            )
            expect(response.body).to have_css(
              "tr[data-submission-id='#{not_started_submission.id}'] ~ tr[data-submission-id='#{completed_submission.id}']"
            )
          end
        end
      end

      context 'when paginating submissions' do
        let!(:submissions) do
          (1..25).map do |n|
            create(:submission, challenge: challenge, phase: phase, title: "submission #{n}")
          end
        end

        it 'returns first page of submissions' do
          get submissions_phase_path(phase)
          expect(response.body).to have_css('tr[data-submission-id]', count: 20)
          expect(response.body).to have_button('Show more')
        end

        it 'returns next page of submissions via partial' do
          get submissions_phase_path(phase, page: 2, partial: true)
          expect(response).to have_http_status(:success)
          expect(response.body).to have_css('tr[data-submission-id]', count: 5)
          expect(response.body).to have_no_button('Show more')
        end

        context 'when sorting by average score' do
          before do
            submissions[0..24].each_with_index do |submission, index|
              submission.update!(judging_status: 'selected')
              assignment = create(:evaluator_submission_assignment, submission: submission, status: :assigned)

              evaluation = create(:evaluation,
                               evaluator_submission_assignment: assignment,
                               submission: submission,
                               completed_at: Time.current)

              evaluation.update_column(:total_score, (25 - index) * 20)
              submission.reload
            end
          end

          it 'paginates and orders submissions by score high to low across pages', bullet: :dont_raise do
            get submissions_phase_path(phase, page: 1, sort: 'average_score_high_to_low')
            expect(response).to have_http_status(:success)

            first_page_submissions = response.body.scan(/data-submission-id="(\d+)"/).flatten.map(&:to_i)
            first_page_scores = response.body.scan(/data-score="(\d+(?:\.\d+)?)"/).flatten.map(&:to_f)
            expect(first_page_submissions.count).to eq(20)
            expect(first_page_scores).to eq(first_page_scores.sort.reverse)
            expect(response.body).to have_button('Show more')

            get submissions_phase_path(phase, page: 2, partial: true, sort: 'average_score_high_to_low')
            second_page_submissions = response.body.scan(/data-submission-id="(\d+)"/).flatten.map(&:to_i)
            second_page_scores = response.body.scan(/data-score="(\d+(?:\.\d+)?)"/).flatten.map(&:to_f)
            expect(second_page_submissions.count).to eq(5)
            expect(second_page_scores).to eq(second_page_scores.sort.reverse)

            all_submissions = first_page_submissions + second_page_submissions
            all_scores = first_page_scores + second_page_scores
            expect(all_scores).to eq(all_scores.sort.reverse)

            expected_order = submissions[0..24].sort_by { |s| [-s.average_score, s.id] }.map(&:id)
            expect(all_submissions).to eq(expected_order)
          end

          it 'paginates and orders submissions by score low to high across pages', bullet: :dont_raise do
            get submissions_phase_path(phase, page: 1, sort: 'average_score_low_to_high')
            expect(response).to have_http_status(:success)

            first_page_submissions = response.body.scan(/data-submission-id="(\d+)"/).flatten.map(&:to_i)
            first_page_scores = response.body.scan(/data-score="(\d+(?:\.\d+)?)"/).flatten.map(&:to_f)
            expect(first_page_submissions.count).to eq(20)
            expect(first_page_scores).to eq(first_page_scores.sort)
            expect(response.body).to have_button('Show more')

            get submissions_phase_path(phase, page: 2, partial: true, sort: 'average_score_low_to_high')
            second_page_submissions = response.body.scan(/data-submission-id="(\d+)"/).flatten.map(&:to_i)
            second_page_scores = response.body.scan(/data-score="(\d+(?:\.\d+)?)"/).flatten.map(&:to_f)
            expect(second_page_submissions.count).to eq(5)
            expect(second_page_scores).to eq(second_page_scores.sort)

            all_submissions = first_page_submissions + second_page_submissions
            all_scores = first_page_scores + second_page_scores
            expect(all_scores).to eq(all_scores.sort)

            expected_order = submissions[0..24].sort_by { |s| [s.average_score, s.id] }.map(&:id)
            expect(all_submissions).to eq(expected_order)
          end
        end

        context 'when filtering submissions' do
          before do
            submissions[0..22].each { |s| s.update!(judging_status: 'selected') }
          end

          it 'paginates correctly with eligible filter' do
            get submissions_phase_path(phase, page: 1, eligible_for_evaluation: 'true')
            expect(response).to have_http_status(:success)
            expect(response.body.scan(/data-submission-id="(\d+)"/).flatten.count).to eq(20)
            expect(response.body).to have_button('Show more')

            get submissions_phase_path(phase, page: 2, partial: true, eligible_for_evaluation: 'true')
            expect(response).to have_http_status(:success)
            expect(response.body.scan(/data-submission-id="(\d+)"/).flatten.count).to eq(3)
          end
        end
      end

      context 'when searching by submission ID' do
        let!(:submission_1) { create(:submission, challenge: challenge, phase: phase, id: 12345) }
        let!(:submission_2) { create(:submission, challenge: challenge, phase: phase, id: 12346) }
        let!(:submission_3) { create(:submission, challenge: challenge, phase: phase, id: 54321) }

        before do
          ChallengeManager.create!(user: user, challenge: challenge)
        end

        it 'finds submissions with exact ID match' do
          get submissions_phase_path(phase), params: { submission_id: '12345' }

          expect(response.body).to have_css("[data-submission-id='#{submission_1.id}']")
          expect(response.body).to have_no_css("[data-submission-id='#{submission_2.id}']")
          expect(response.body).to have_no_css("[data-submission-id='#{submission_3.id}']")
        end

        it 'finds submissions with partial ID match' do
          get submissions_phase_path(phase), params: { submission_id: '123' }

          expect(response.body).to have_css("[data-submission-id='#{submission_1.id}']")
          expect(response.body).to have_css("[data-submission-id='#{submission_2.id}']")
          expect(response.body).to have_no_css("[data-submission-id='#{submission_3.id}']")
        end

        it 'returns no results for non-matching IDs' do
          get submissions_phase_path(phase), params: { submission_id: '99999' }

          expect(response.body).to have_no_css("[data-submission-id]")
          expect(response.body).to include("No submissions found.")
        end
      end

      context "with a non gov email" do
        before do
          user.update(email: generate_user_email(type: :non_gov))
        end

        it "prevents access and redirects" do
          challenge = create(:challenge, title: "Star Spangled Banister")
          phase = create(:phase, challenge: challenge)
          create(:challenge_manager, user:, challenge:)

          get submissions_phase_path(phase)

          expect(response).to have_http_status(:redirect)
        end
      end
    end
  end
end
