require 'rails_helper'

RSpec.describe "Evaluations" do
  describe "GET /index" do
    context "when logged in as an super admin" do
      before do
        create_and_log_in_user(role: "super_admin")
      end

      it "redirects to the phoenix app" do
        get evaluations_path

        expect(response).to redirect_to(ENV.fetch("PHOENIX_URI", nil))
      end
    end

    context "when logged in as an admin" do
      before do
        create_and_log_in_user(role: "admin")
      end

      it "redirects to the phoenix app" do
        get evaluations_path

        expect(response).to redirect_to(ENV.fetch("PHOENIX_URI", nil))
      end
    end

    context "when logged in as a challenge manager" do
      before do
        create_and_log_in_user(role: "challenge_manager")
      end

      it "redirects to the challenge manager landing page" do
        get evaluations_path

        expect(response).to redirect_to(phases_path)
      end
    end

    context "when logged in as an evaluator" do
      before do
        create_and_log_in_user(role: "evaluator", status: "active")
        get "/evaluations"
      end

      it_behaves_like "a page with footer content"
      it_behaves_like "a page with header content"
      it_behaves_like "a page with utility menu links for all users"
      it_behaves_like "a page with utility menu links for an evaluator"

      it "renders the index view with the correct content" do
        get evaluations_path

        expect(response).to have_http_status(:success)
        expect(response.body).to include("Evaluations")
        expect(response.body).to include("Resources and support")
      end
    end

    context "when logged in as a solver" do
      before do
        create_and_log_in_user(role: "solver")
      end

      it "redirects to the phoenix app" do
        get evaluations_path

        expect(response).to redirect_to(ENV.fetch("PHOENIX_URI", nil))
      end
    end

    context "when logged in as an evaluator" do
      let(:evaluator) { create_and_log_in_user(role: 'evaluator', status: 'active') }

      let(:challenge_with_submissions) do
        create(:challenge, title: "Challenge with Submissions", is_multi_phase: false)
      end
      let(:phase_with_submissions) { challenge_with_submissions.phases.first }

      let(:multi_phase_challenge) { create(:challenge, title: "Multi-Phase Challenge", is_multi_phase: true) }
      let(:phase1) { create(:phase, challenge: multi_phase_challenge) }
      let(:phase2) { create(:phase, challenge: multi_phase_challenge) }

      let(:challenge_without_submissions) do
        create(:challenge, title: "Challenge without Submissions", is_multi_phase: false)
      end
      let(:phase_without_submissions) { challenge_without_submissions.phases.first }

      before do
        ChallengePhasesEvaluator.create!(challenge: challenge_with_submissions, phase: phase_with_submissions,
                                         user: evaluator)
        ChallengePhasesEvaluator.create!(challenge: multi_phase_challenge, phase: phase1, user: evaluator)
        ChallengePhasesEvaluator.create!(challenge: challenge_without_submissions, phase: phase_without_submissions,
                                         user: evaluator)
      end

      it "only shows phases with assigned or recused submissions" do
        # Submissions for single phase challenge
        assigned_submission = create(:submission, phase: phase_with_submissions, challenge: challenge_with_submissions)
        create(:evaluator_submission_assignment,
               submission: assigned_submission,
               evaluator: evaluator,
               status: :assigned)

        recused_submission = create(:submission, phase: phase_with_submissions, challenge: challenge_with_submissions)
        create(:evaluator_submission_assignment,
               submission: recused_submission,
               evaluator: evaluator,
               status: :recused)

        unassigned_submission = create(:submission, phase: phase_with_submissions,
                                                    challenge: challenge_with_submissions)
        create(:evaluator_submission_assignment,
               submission: unassigned_submission,
               evaluator: evaluator,
               status: :unassigned)

        recused_unassigned_submission = create(:submission, phase: phase_with_submissions,
                                                            challenge: challenge_with_submissions)
        create(:evaluator_submission_assignment,
               submission: recused_unassigned_submission,
               evaluator: evaluator,
               status: :recused_unassigned)

        # Submissions for multi-phase challenge
        multi_phase_submission = create(:submission, phase: phase1, challenge: multi_phase_challenge)
        create(:evaluator_submission_assignment,
               submission: multi_phase_submission,
               evaluator: evaluator,
               status: :assigned)

        multi_phase_recused_submission = create(:submission, phase: phase1, challenge: multi_phase_challenge)
        create(:evaluator_submission_assignment,
               submission: multi_phase_recused_submission,
               evaluator: evaluator,
               status: :recused)

        multi_phase_unassigned_submission = create(:submission, phase: phase1, challenge: multi_phase_challenge)
        create(:evaluator_submission_assignment,
               submission: multi_phase_unassigned_submission,
               evaluator: evaluator,
               status: :unassigned)

        multi_phase_recused_unassigned_submission = create(:submission, phase: phase1, challenge: multi_phase_challenge)
        create(:evaluator_submission_assignment,
               submission: multi_phase_recused_unassigned_submission,
               evaluator: evaluator,
               status: :recused_unassigned)

        get evaluations_path

        expect(response.body).to include(challenge_with_submissions.title)
        expect(response.body).not_to include(challenge_without_submissions.title)

        expect(response.body.scan('data-label="Challenge Title"').count).to eq(2)
        expect(response.body.scan(/#{multi_phase_challenge.title}/).count).to eq(1)

        within("#phase_#{phase_with_submissions.id}") do
          expect(page).to have_css('td[data-label="Assigned to me"]', text: '2')
        end

        within("#phase_#{phase1.id}") do
          expect(page).to have_css('td[data-label="Assigned to me"]', text: '2')
        end
      end
    end

    context "when evaluator status authorization" do
      let(:challenge) { create(:challenge) }
      let(:phase) { create(:phase, challenge: challenge) }
      let(:submission) { create(:submission, phase: phase, challenge: challenge) }
      let(:evaluation_form) { create(:evaluation_form, phase: phase, challenge: challenge) }

      context "when evaluator is pending" do
        let(:pending_evaluator) { create(:user, role: 'evaluator', status: 'pending') }

        before do
          log_in_user(pending_evaluator)
          ChallengePhasesEvaluator.create!(challenge: challenge, phase: phase, user: pending_evaluator)
        end

        it "cannot access evaluations index" do
          get evaluations_path
          expect(response).to redirect_to("/")
          expect(flash[:alert]).to eq(I18n.t("evaluator_pending_approval"))
        end

        it "cannot access submissions page" do
          get submissions_evaluation_path(phase)
          expect(response).to redirect_to("/")
          expect(flash[:alert]).to eq(I18n.t("evaluator_pending_approval"))
        end

        it "cannot access new evaluation page" do
          get new_submission_evaluation_path(submission)
          expect(response).to redirect_to("/")
          expect(flash[:alert]).to eq(I18n.t("evaluator_pending_approval"))
        end

        it "cannot access edit evaluation page" do
          evaluation = create(:evaluation, user: pending_evaluator, evaluation_form: evaluation_form)
          get edit_evaluation_path(evaluation)
          expect(response).to redirect_to("/")
          expect(flash[:alert]).to eq(I18n.t("evaluator_pending_approval"))
        end
      end

      context "when evaluator is active" do
        let(:active_evaluator) { create(:user, role: 'evaluator', status: 'active') }
        let!(:evaluation_form) { create(:evaluation_form, phase: phase, challenge: challenge) }
        let!(:assignment) do
          create(:evaluator_submission_assignment,
                 submission: submission,
                 evaluator: active_evaluator,
                 status: :assigned)
        end

        before do
          log_in_user(active_evaluator)
          ChallengePhasesEvaluator.create!(challenge: challenge, phase: phase, user: active_evaluator)
        end

        it "can access evaluations index" do
          get evaluations_path
          expect(response).to have_http_status(:success)
        end

        it "can access submissions page" do
          get submissions_evaluation_path(phase)
          expect(response).to have_http_status(:success)
        end

        it "can access new evaluation page" do
          get new_submission_evaluation_path(submission)
          expect(response).to have_http_status(:success)
        end
      end
    end
  end

  describe "GET /evaluations/:id/submissions" do
    let(:evaluator) { create(:user, role: 'evaluator', status: 'active') }
    let(:challenge) { create(:challenge) }
    let(:phase) { create(:phase, challenge: challenge) }
    let!(:evaluation_form) { create(:evaluation_form, phase: phase, challenge: challenge) }

    context "when logged in as an evaluator" do
      before do
        log_in_user(evaluator)
        ChallengePhasesEvaluator.create!(challenge: challenge, phase: phase, user: evaluator)
      end

      context "with assigned submissions" do
        let(:submission) { create(:submission, phase: phase, challenge: challenge) }
        let!(:assignment) do
          create(:evaluator_submission_assignment,
                 submission: submission,
                 evaluator: evaluator,
                 status: :assigned)
        end

        it "displays the submissions page successfully" do
          get submissions_evaluation_path(phase)

          expect(response).to have_http_status(:success)
          expect(response.body).to include("Submissions Assigned to Me")
        end

        it "shows assigned submissions" do
          get submissions_evaluation_path(phase)

          expect(response.body).to include(submission.id.to_s)
        end

        it "shows submission counts", bullet: :dont_raise do
          create(:evaluation,
                 evaluator_submission_assignment: assignment,
                 completed_at: Time.current)

          in_progress_submission = create(:submission, phase: phase)
          in_progress_assignment = create(:evaluator_submission_assignment,
                                          submission: in_progress_submission,
                                          evaluator: evaluator,
                                          status: :assigned)
          create(:evaluation,
                 evaluator_submission_assignment: in_progress_assignment,
                 completed_at: nil)

          not_started_submission = create(:submission, phase: phase)
          create(:evaluator_submission_assignment,
                 submission: not_started_submission,
                 evaluator: evaluator,
                 status: :assigned)

          get submissions_evaluation_path(phase)

          expect(response.body).to include("Completed")
          expect(response.body).to include("In Progress")
          expect(response.body).to include("Not")
          expect(response.body).to include("Started")

          expect(response.body).to have_css(".bg-green-cool-vivid-60v .font-sans-xl.text-white.text-bold", text: "1")
          expect(response.body).to have_css(".bg-orange-warm-vivid-50v .font-sans-xl.text-white.text-bold", text: "1")
          expect(response.body).to have_css(".bg-red-vivid-60v .font-sans-xl.text-white.text-bold", text: "1")
        end
      end

      context "with no submissions" do
        it "shows empty state message" do
          get submissions_evaluation_path(phase)

          expect(response.body).to include("This challenge phase does not currently have any submissions.")
        end
      end
    end

    context "when logged in as an evaluator not associated with the challenge phase" do
      let(:unassociated_evaluator) { create(:user, role: 'evaluator', status: 'active') }
      let(:other_challenge) { create(:challenge) }
      let(:other_phase) { create(:phase, challenge: other_challenge) }

      before do
        log_in_user(unassociated_evaluator)
        ChallengePhasesEvaluator.create!(
          challenge: other_challenge,
          phase: other_phase,
          user: unassociated_evaluator
        )
        ChallengePhasesEvaluator.create!(
          challenge: challenge,
          phase: phase,
          user: evaluator
        )
      end

      it "cannot access a challenge phase when not associated" do
        get submissions_evaluation_path(phase)
        expect(response).to have_http_status(:not_found)
      end

      it "can access their associated phase" do
        get submissions_evaluation_path(other_phase)
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "GET /evaluations/:id/revision" do
    let(:evaluator) { create(:user, role: 'evaluator', status: 'active') }
    let(:challenge_manager) { create(:user, role: 'challenge_manager') }
    let(:challenge) { create(:challenge) }
    let(:phase) { create(:phase, challenge: challenge) }
    let(:evaluation_form) { create(:evaluation_form, phase: phase, challenge: challenge) }
    let(:submission) { create(:submission, challenge:, phase: phase) }
    let!(:assignment) do
      create(:evaluator_submission_assignment,
             submission: submission,
             evaluator: evaluator,
             status: :assigned)
    end

    context "when logged in as an evaluator" do
      before do
        log_in_user(evaluator)
        ChallengePhasesEvaluator.create!(challenge: challenge, phase: phase, user: evaluator)
      end

      context "with assigned submissions" do
        it "does not allow viewing the revision for my own evaluation" do
          evaluation = create(:evaluation,
                              evaluation_form:,
                              submission:,
                              user: evaluator,
                              evaluator_submission_assignment: assignment)

          # redirected to landing page
          get revision_evaluation_path(evaluation)
          expect(response).to redirect_to(evaluations_path)
          follow_redirect!
          expect(response.body).to have_css('p.usa-alert__text', text: I18n.t("access_denied"))
        end
      end
    end

    context "when logged in as a challenge manager" do
      before do
        log_in_user(challenge_manager)
        ChallengeManager.create(challenge:, user: challenge_manager)
        ChallengePhasesEvaluator.create!(challenge: challenge, phase: phase, user: evaluator)
      end

      it "does not allow viewing revision for a draft evaluation", bullet: :dont_raise do
        evaluation = create(:evaluation,
                            evaluation_form:,
                            submission:,
                            user: evaluator,
                            evaluator_submission_assignment: assignment)

        # redirected to landing page
        get revision_evaluation_path(evaluation)
        expect(response).to redirect_to(submission_path(submission))
        follow_redirect!
        expect(response.body).to have_css('div.usa-alert__body',
                                          text: I18n.t("evaluation_overrides.alerts.not_found"))
      end

      it "does allow viewing revision for a completed evaluation", bullet: :dont_raise do
        evaluation = create(:evaluation,
                            evaluation_form:,
                            submission:,
                            user: evaluator,
                            evaluator_submission_assignment: assignment,
                            completed_at: Time.current)

        # redirected to landing page
        get revision_evaluation_path(evaluation)
        expect(response).to have_http_status(:success)
        expect(response.body).to have_css('h2',
                                          text: "#{evaluation.user.full_name}'s Evaluation for Submission ID #{evaluation.submission.id}")
      end
    end
  end

  # new_submission_evaluation_path
  describe "GET /evaluator_submission_assignments/:evaluator_submission_assignment_id/evaluations/new" do
    context "when logged in as an evaluator" do
      let(:current_user) { create_user(role: "evaluator", status: "active") }
      let(:challenge) { create(:challenge) }
      let(:phase) { create(:phase, challenge:) }
      let(:submission) { create(:submission, challenge:, phase:) }
      let!(:evaluator_submission_assignment) do
        create(:evaluator_submission_assignment, user_id: current_user.id, submission:)
      end

      before { log_in_user(current_user) }

      it "takes me to the new evaluation page if I was assigned to the submission" do
        evaluation_form = create(:evaluation_form, challenge:, phase:)

        get new_submission_evaluation_path(submission)

        expect(response).to have_http_status(:success)

        evaluation = assigns(:evaluation)
        expect(evaluation.user_id).to eq(current_user.id)
        expect(evaluation.evaluation_form_id).to eq(evaluation_form.id)
        expect(evaluation.submission_id).to eq(evaluator_submission_assignment.submission_id)
        expect(evaluation.evaluator_submission_assignment_id).to eq(evaluator_submission_assignment.id)

        criteria_ids = evaluation.evaluation_form.evaluation_criteria.pluck(:id)
        score_criteria_ids = evaluation.evaluation_scores.map(&:evaluation_criterion_id)

        expect(score_criteria_ids).to match_array(criteria_ids)
      end

      it "redirects me to my evaluations if I was not assigned to the submission" do
        user = create(:user, :evaluator)
        evaluator_submission_assignment = create(:evaluator_submission_assignment, user_id: user.id)
        create(:evaluation_form, phase: evaluator_submission_assignment.phase)

        get new_submission_evaluation_path(evaluator_submission_assignment.submission_id)

        expect(response).to redirect_to(evaluations_path)
        expect(flash[:alert]).to eq(I18n.t("evaluations.alerts.evaluator_submission_assignment_not_found"))
      end

      it "redirects me to my evaluations if the submission assignment was not found" do
        get new_submission_evaluation_path("missing")

        expect(response).to redirect_to(evaluations_path)
        expect(flash[:alert]).to eq(I18n.t("evaluations.alerts.evaluator_submission_assignment_not_found"))
      end

      it "redirects me to my evaluations if the submission assignment has no evaluation form" do
        # No evaluation form is currently created for the phase by default in the factory
        evaluator_submission_assignment = create(:evaluator_submission_assignment, user_id: current_user.id)

        get new_submission_evaluation_path(evaluator_submission_assignment.submission_id)
        expect(response).to redirect_to(evaluations_path)
      end
    end
  end

  # evaluations_path
  describe "POST /evaluations" do
    context "when logged in as an evaluator" do
      let(:current_user) { create_user(role: "evaluator", status: "active") }

      before { log_in_user(current_user) }

      it "allows me to save a draft of my new evaluation to skip validations and not set completed_at" do
        evaluator_submission_assignment = create(:evaluator_submission_assignment, user_id: current_user.id)
        evaluation_form = create(:evaluation_form, phase: evaluator_submission_assignment.phase)

        evaluation = build_evaluation(evaluator_submission_assignment)
        evaluation_params = build_evaluation_params(evaluation)

        # Nullify scores to test draft saving skipping validations
        evaluation_params[:evaluation_scores_attributes].each_value do |value|
          value[:score] = nil
          value[:comment] = nil
        end

        expect do
          post evaluations_path, params: { evaluation: evaluation_params, subaction: "save_draft" }
        end.to change { Evaluation.count }

        saved_evaluation = Evaluation.last

        expect(saved_evaluation.completed_at).to be_nil
        expect(saved_evaluation.evaluation_scores.count).to eq(evaluation_form.evaluation_criteria.count)
        saved_evaluation.evaluation_scores.each do |score|
          expect(score.score).to be_nil
          expect(score.comment).to be_nil
        end

        expect(response).to redirect_to(submissions_evaluation_path(evaluator_submission_assignment.phase))
        expect(flash[:custom_success_heading]).to eq(I18n.t('evaluations.success.save_draft_heading'))
        expect(flash[:custom_success_description]).to eq(I18n.t('evaluations.success.save_draft_description'))
      end

      it "does not allow me to save a draft evaluation for a submission I'm not assigned to" do
        user = create(:user, :evaluator)
        evaluator_submission_assignment = create(:evaluator_submission_assignment, user_id: user.id)
        create(:evaluation_form, phase: evaluator_submission_assignment.phase)

        evaluation = build_evaluation(evaluator_submission_assignment)
        evaluation_params = build_evaluation_params(evaluation)

        # Nullify scores to test draft saving skipping validations
        evaluation_params[:evaluation_scores_attributes].each_value do |value|
          value[:score] = nil
          value[:comment] = nil
        end

        expect do
          post evaluations_path, params: { evaluation: evaluation_params, subaction: "save_draft" }
        end.not_to change { Evaluation.count }

        expect(response).to redirect_to(evaluations_path)
        expect(flash[:alert]).to eq(I18n.t("evaluations.alerts.unauthorized"))
      end
    end
  end

  describe "POST /evaluations" do
    context "when logged in as an evaluator" do
      let(:current_user) { create_user(role: "evaluator", status: "active") }

      before { log_in_user(current_user) }

      it "allows me to mark my new evaluation as complete" do
        evaluator_submission_assignment = create(:evaluator_submission_assignment, user_id: current_user.id)
        evaluation_form = create(:evaluation_form, phase: evaluator_submission_assignment.phase)

        evaluation = build_evaluation(evaluator_submission_assignment)
        evaluation_params = build_evaluation_params(evaluation)

        expect do
          post evaluations_path, params: { evaluation: evaluation_params, subaction: "mark_complete" }
        end.to change { Evaluation.count }

        saved_evaluation = Evaluation.last

        expect(saved_evaluation.completed_at).not_to be_nil
        expect(saved_evaluation.evaluation_scores.count).to eq(evaluation_form.evaluation_criteria.count)
        saved_evaluation.evaluation_scores.each do |score|
          expect(score.score).not_to be_nil
        end

        expect(response).to redirect_to(submissions_evaluation_path(evaluator_submission_assignment.phase))
        expect(flash[:custom_success_heading]).to eq(I18n.t('evaluations.success.mark_complete_heading'))
        expect(flash[:custom_success_description]).to eq(I18n.t('evaluations.success.mark_complete_description'))
      end

      it "does not allow me to mark my new evaluation as complete if it fails validations" do
        challenge = create(:challenge)
        phase = create(:phase, challenge:)
        submission = create(:submission, challenge:, phase:)

        evaluator_submission_assignment = create(:evaluator_submission_assignment, user_id: current_user.id,
                                                                                   submission:)
        create(:evaluation_form, phase: evaluator_submission_assignment.phase)

        evaluation = build_evaluation(evaluator_submission_assignment)
        evaluation_params = build_evaluation_params(evaluation)

        # Nullify scores to test marking as complete fail validations
        evaluation_params[:evaluation_scores_attributes].each_value do |value|
          value[:score] = nil
          value[:comment] = nil
        end

        expect do
          post evaluations_path, params: { evaluation: evaluation_params, subaction: "mark_complete" }
        end.not_to change { Evaluation.count }

        assigns(:evaluation)

        expect(response).to render_template(:show)
        expect(assigns(:evaluation).errors).not_to be_empty
      end

      it "does not allow me to mark my new evaluation as complete for a submission I'm not assigned to" do
        user = create(:user, :evaluator)
        evaluator_submission_assignment = create(:evaluator_submission_assignment, user_id: user.id)
        create(:evaluation_form, phase: evaluator_submission_assignment.phase)

        evaluation = build_evaluation(evaluator_submission_assignment)
        evaluation_params = build_evaluation_params(evaluation)

        expect do
          post evaluations_path, params: { evaluation: evaluation_params, subaction: "mark_complete" }
        end.not_to change { Evaluation.count }

        expect(response).to redirect_to(evaluations_path)
        follow_redirect!
        expect(flash[:alert]).to eq(I18n.t("evaluations.alerts.unauthorized"))
      end
    end
  end

  # edit_evaluation_path
  describe "GET /evaluations/:id/edit" do
    context "when logged in as an evaluator" do
      let(:current_user) { create_user(role: "evaluator", status: "active") }
      let(:challenge) { create(:challenge) }
      let(:phase) { create(:phase, challenge:) }
      let(:submission) { create(:submission, challenge:, phase:) }

      before { log_in_user(current_user) }

      it "allows me to view an existing draft evaluation I created" do
        evaluator_submission_assignment = create(:evaluator_submission_assignment, user_id: current_user.id,
                                                                                   submission:)
        evaluation_form = create(:evaluation_form, phase:)

        evaluation = create(:evaluation,
                            user: current_user,
                            evaluation_form: evaluation_form,
                            submission: evaluator_submission_assignment.submission,
                            evaluator_submission_assignment: evaluator_submission_assignment)

        get edit_evaluation_path(evaluation)
        expect(response).to have_http_status(:success)

        evaluation = assigns(:evaluation)

        expect(evaluation.user_id).to eq(current_user.id)
        expect(evaluation.evaluation_form_id).to eq(evaluation_form.id)
        expect(evaluation.submission_id).to eq(evaluator_submission_assignment.submission_id)
        expect(evaluation.evaluator_submission_assignment_id).to eq(evaluator_submission_assignment.id)

        criteria_ids = evaluation.evaluation_form.evaluation_criteria.pluck(:id)
        score_criteria_ids = evaluation.evaluation_scores.map(&:evaluation_criterion_id)

        expect(score_criteria_ids).to match_array(criteria_ids)
      end

      it "allows me to view an existing complete evaluation I created", bullet: :dont_raise do
        evaluator_submission_assignment = create(:evaluator_submission_assignment, user_id: current_user.id,
                                                                                   submission:)
        evaluation_form = create(:evaluation_form, phase:)

        evaluation = create(:evaluation,
                            user: current_user,
                            evaluation_form: evaluation_form,
                            submission: evaluator_submission_assignment.submission,
                            evaluator_submission_assignment: evaluator_submission_assignment,
                            completed_at: Time.current)

        get edit_evaluation_path(evaluation)
        expect(response).to have_http_status(:success)

        evaluation = assigns(:evaluation)

        expect(evaluation.user_id).to eq(current_user.id)
        expect(evaluation.evaluation_form_id).to eq(evaluation_form.id)
        expect(evaluation.submission_id).to eq(evaluator_submission_assignment.submission_id)
        expect(evaluation.evaluator_submission_assignment_id).to eq(evaluator_submission_assignment.id)

        criteria_ids = evaluation.evaluation_form.evaluation_criteria.pluck(:id)
        score_criteria_ids = evaluation.evaluation_scores.map(&:evaluation_criterion_id)

        expect(score_criteria_ids).to match_array(criteria_ids)
      end

      it "redirects me if I try to view an evaluation I did not create", bullet: :dont_raise do
        user = create(:user, :evaluator)
        evaluator_submission_assignment = create(:evaluator_submission_assignment, user_id: user.id)
        evaluation_form = create(:evaluation_form, phase: evaluator_submission_assignment.phase)

        evaluation = create(:evaluation,
                            user: user,
                            evaluation_form: evaluation_form,
                            submission: evaluator_submission_assignment.submission,
                            evaluator_submission_assignment: evaluator_submission_assignment)

        get edit_evaluation_path(evaluation)

        expect(response).to redirect_to(evaluations_path)
        expect(flash[:alert]).to eq(I18n.t("evaluations.alerts.unauthorized"))
      end
    end
  end

  describe "PATCH /evaluations/:id" do
    context "when logged in as an evaluator" do
      let(:current_user) { create_user(role: "evaluator", status: "active") }

      before { log_in_user(current_user) }

      describe "draft evaluations" do
        it "allows me to save a draft of my existing evaluation to skip validations and not set completed_at",
           bullet: :dont_raise do
          evaluator_submission_assignment = create(:evaluator_submission_assignment, user_id: current_user.id)
          evaluation_form = create(:evaluation_form, phase: evaluator_submission_assignment.phase)

          evaluation = create(:evaluation,
                              user: current_user,
                              evaluation_form: evaluation_form,
                              submission: evaluator_submission_assignment.submission,
                              evaluator_submission_assignment: evaluator_submission_assignment)

          evaluation_params = build_patch_evaluation_params(evaluation)

          evaluation_params = evaluation_params.merge(additional_comments: "Test")

          # Nullify scores to test draft saving skipping validations
          evaluation_params[:evaluation_scores_attributes].each_value do |value|
            value[:score] = nil
            value[:comment] = nil
          end

          patch evaluation_path(evaluation, params: { evaluation: evaluation_params, subaction: "save_draft" })

          updated_evaluation = assigns(:evaluation)

          expect(updated_evaluation).to be_persisted
          expect(updated_evaluation.additional_comments).to eq("Test")

          expect(updated_evaluation.errors).to be_empty
          expect(updated_evaluation.completed_at).to be_nil

          expect(response).to redirect_to(submissions_evaluation_path(evaluator_submission_assignment.phase))
          expect(flash[:custom_success_heading]).to eq(I18n.t('evaluations.success.save_draft_heading'))
          expect(flash[:custom_success_description]).to eq(I18n.t('evaluations.success.save_draft_description'))
        end

        it "does not allow me to save a draft of an evaluation I did not create", bullet: :dont_raise do
          user = create(:user, :evaluator)
          evaluator_submission_assignment = create(:evaluator_submission_assignment, user_id: user.id)
          evaluation_form = create(:evaluation_form, phase: evaluator_submission_assignment.phase)

          evaluation = create(:evaluation,
                              user: user,
                              evaluation_form: evaluation_form,
                              submission: evaluator_submission_assignment.submission,
                              evaluator_submission_assignment: evaluator_submission_assignment)

          evaluation_params = { additional_comments: "Test" }

          patch evaluation_path(evaluation, params: { evaluation: evaluation_params, subaction: "save_draft" })

          expect(response).to redirect_to(evaluations_path)
          expect(flash[:alert]).to eq(I18n.t("evaluations.alerts.unauthorized"))
        end
      end

      describe "complete evaluations" do
        it "allows me to mark my existing evaluation as complete", bullet: :dont_raise do
          evaluator_submission_assignment = create(:evaluator_submission_assignment, user_id: current_user.id)
          evaluation_form = create(:evaluation_form, phase: evaluator_submission_assignment.phase)

          evaluation = create(:evaluation,
                              user: current_user,
                              evaluation_form: evaluation_form,
                              submission: evaluator_submission_assignment.submission,
                              evaluator_submission_assignment: evaluator_submission_assignment)

          evaluation_params = { additional_comments: "Test" }

          patch evaluation_path(evaluation, params: { evaluation: evaluation_params, subaction: "mark_complete" })

          updated_evaluation = assigns(:evaluation)

          expect(updated_evaluation).to be_persisted
          expect(updated_evaluation.additional_comments).to eq("Test")

          expect(updated_evaluation.errors).to be_empty
          expect(updated_evaluation.completed_at).not_to be_nil

          expect(response).to redirect_to(submissions_evaluation_path(evaluator_submission_assignment.phase))
          expect(flash[:custom_success_heading]).to eq(I18n.t('evaluations.success.mark_complete_heading'))
          expect(flash[:custom_success_description]).to eq(I18n.t('evaluations.success.mark_complete_description'))
        end

        it "does not allow me to mark my existing evaluation as complete if it fails validations",
           bullet: :dont_raise do
          challenge = create(:challenge)
          phase = create(:phase, challenge:)
          submission = create(:submission, challenge:, phase:)

          evaluator_submission_assignment = create(:evaluator_submission_assignment, submission:,
                                                                                     user_id: current_user.id)

          evaluation_form = create(:evaluation_form, phase: evaluator_submission_assignment.phase)

          evaluation = create(:evaluation,
                              user: current_user,
                              evaluation_form: evaluation_form,
                              submission: evaluator_submission_assignment.submission,
                              evaluator_submission_assignment: evaluator_submission_assignment)

          evaluation_params = build_patch_evaluation_params(evaluation)

          # Nullify scores to test draft saving skipping validations
          evaluation_params[:evaluation_scores_attributes].each_value do |value|
            value[:score] = nil
            value[:comment] = nil
          end

          patch evaluation_path(evaluation, params: { evaluation: evaluation_params, subaction: "mark_complete" })

          failed_evaluation = assigns(:evaluation)
          evaluation_record = Evaluation.find_by(id: failed_evaluation.id)

          expect(failed_evaluation.completed_at).to be_nil
          expect(evaluation_record.completed_at).to be_nil

          expect(response).to render_template(:show)
          expect(assigns(:evaluation).errors).not_to be_empty
        end

        it "does not allow me to mark an evaluation I did not create as complete", bullet: :dont_raise do
          user = create(:user, :evaluator)
          evaluator_submission_assignment = create(:evaluator_submission_assignment, user_id: user.id)
          evaluation_form = create(:evaluation_form, phase: evaluator_submission_assignment.phase)

          evaluation = create(:evaluation,
                              user: user,
                              evaluation_form: evaluation_form,
                              submission: evaluator_submission_assignment.submission,
                              evaluator_submission_assignment: evaluator_submission_assignment)

          evaluation_params = { additional_comments: "Test" }

          patch evaluation_path(evaluation, params: { evaluation: evaluation_params, subaction: "mark_complete" })

          expect(response).to redirect_to(evaluations_path)
          expect(flash[:alert]).to eq(I18n.t("evaluations.alerts.unauthorized"))
        end
      end
    end
  end

  # recuse on a new evaluation that has not been started
  describe "PATCH /submissions/:submission_id/evaluations/recuse" do
    context "when logged in as an evaluator" do
      let(:current_user) { create_user(role: "evaluator", status: "active") }

      before { log_in_user(current_user) }

      context "when the evaluation does not exist" do
        let(:challenge) { create(:challenge) }
        let(:phase) { create(:phase, challenge: challenge) }
        let(:submission) { create(:submission, phase: phase, challenge: challenge) }
        let!(:evaluator_submission_assignment) do
          create(:evaluator_submission_assignment,
                 submission: submission,
                 evaluator: current_user,
                 status: :assigned)
        end

        it "successfully recuses without an evaluation" do
          expect do
            patch recuse_submission_evaluations_path(submission)
          end.to change { evaluator_submission_assignment.reload.status }.from("assigned").to("recused").
            and change { ActionMailer::Base.deliveries.count }.by(1)

          mail = ActionMailer::Base.deliveries.last
          expect(mail.subject).to eq(I18n.t("mailers.recusal.subject", submission_id: submission.id))

          expect(response).to redirect_to(submissions_evaluation_path(phase))
          expect(flash[:custom_success_heading]).to eq(I18n.t('evaluations.success.evaluator_recusal_heading'))
          expect(flash[:custom_success_description]).to eq(I18n.t('evaluations.success.evaluator_recusal_description'))
        end

        context "when recusal update fails" do
          before do
            allow_any_instance_of(EvaluatorRecusalService).to receive(:call).and_return(false)
          end

          it "handles recusal failure" do
            patch recuse_submission_evaluations_path(submission)

            expect(flash[:alert]).to eq(I18n.t("evaluations.alerts.unauthorized"))
            expect(response).to redirect_to(evaluations_path)
          end
        end
      end

      # recuse on an existing evaluation that is in progress or completed
      context "when logged in as an evaluator" do
        let(:challenge) { create(:challenge) }
        let(:phase) { create(:phase, challenge: challenge) }
        let(:submission) { create(:submission, phase: phase, challenge: challenge) }
        let(:challenge_manager) { create(:user, role: "challenge_manager") }
        let(:evaluation_form) { create(:evaluation_form, phase: phase, challenge: challenge) }
        let(:evaluator_submission_assignment) do
          create(:evaluator_submission_assignment,
                 submission: submission,
                 evaluator: current_user,
                 status: :assigned)
        end
        let!(:evaluation) do
          create(:evaluation,
                 user: current_user,
                 evaluation_form: evaluation_form,
                 submission: submission,
                 evaluator_submission_assignment: evaluator_submission_assignment,
                 completed_at: Time.current)
        end

        before do
          log_in_user(current_user)
          create(:challenge_manager, user: challenge_manager, challenge: challenge)
        end

        it "destroys evaluation and sends recusal notification email when recusing" do
          expect do
            patch recuse_submission_evaluations_path(submission)
          end.to change { Evaluation.count }.by(-1).
            and change { evaluator_submission_assignment.reload.status }.to("recused").
            and change { ActionMailer::Base.deliveries.count }.by(1)

          mail = ActionMailer::Base.deliveries.last
          expect(mail.subject).to eq(I18n.t("mailers.recusal.subject", submission_id: submission.id))
          expect(mail.to).to match_array(challenge.challenge_managers.map(&:user).map(&:email))

          expect(response).to redirect_to(submissions_evaluation_path(phase))
          expect(flash[:custom_success_heading]).to eq(I18n.t('evaluations.success.evaluator_recusal_heading'))
          expect(flash[:custom_success_description]).to eq(I18n.t('evaluations.success.evaluator_recusal_description'))
        end

        it "prevents unauthorized recusal of another evaluator's evaluation" do
          submission = create(:submission, phase: phase)
          other_evaluator = create(:user, :evaluator)
          other_assignment = create(:evaluator_submission_assignment,
                                    submission: submission,
                                    evaluator: other_evaluator,
                                    status: :assigned)
          create(:evaluation,
                 user: other_evaluator,
                 evaluation_form: evaluation_form,
                 submission: submission,
                 evaluator_submission_assignment: other_assignment)

          # patch recuse_evaluation_path(other_evaluation)
          patch recuse_submission_evaluations_path(submission)

          expect(response).to redirect_to(evaluations_path)
          expect(flash[:alert]).to eq(I18n.t("evaluations.alerts.unauthorized"))
        end

        context "when recusal update fails" do
          before do
            allow_any_instance_of(Evaluation).to receive(:destroy!).and_raise(ActiveRecord::RecordInvalid.new(evaluation))
          end

          it "handles recusal failure" do
            patch recuse_submission_evaluations_path(submission)

            expect(flash[:alert]).to eq(I18n.t("evaluations.alerts.unauthorized"))
            expect(response).to redirect_to(evaluations_path)
          end
        end
      end
    end
  end

  def build_evaluation(evaluator_submission_assignment)
    evaluator_submission_assignment.evaluator
    evaluation_form = evaluator_submission_assignment.phase.evaluation_form
    submission = evaluator_submission_assignment.submission

    evaluation = Evaluation.new(
      # user: user,
      evaluation_form: evaluation_form,
      submission: submission,
      evaluator_submission_assignment: evaluator_submission_assignment
    )

    evaluation_form.evaluation_criteria.each do |criterion|
      evaluation.evaluation_scores.build(evaluation_criterion: criterion)
    end

    evaluation
  end

  def build_evaluation_params(evaluation)
    {
      # user_id: evaluation.user_id,
      evaluator_submission_assignment_id: evaluation.evaluator_submission_assignment_id,
      submission_id: evaluation.evaluator_submission_assignment.submission_id,
      evaluation_form_id: evaluation.evaluation_form_id,
      evaluation_scores_attributes: evaluation.evaluation_scores.to_h do |score|
        [SecureRandom.hex(8),
         {
           evaluation_criterion_id: score.evaluation_criterion_id,
           score: valid_score_for_criterion(score),
           comment: Faker::Lorem.sentence
         }]
      end
    }
  end

  def build_patch_evaluation_params(evaluation)
    {
      additional_comments: evaluation.additional_comments,
      revision_comments: evaluation.revision_comments,
      evaluation_scores_attributes: evaluation.evaluation_scores.to_h do |score, _i|
        [SecureRandom.hex(8),
         {
           id: score.id,
           evaluation_criterion_id: score.evaluation_criterion_id,
           score: valid_score_for_criterion(score),
           comment: Faker::Lorem.sentence
         }]
      end
    }
  end
end
