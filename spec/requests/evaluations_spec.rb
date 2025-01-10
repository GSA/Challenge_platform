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

      it "redirects to the dashboard" do
        get evaluations_path

        expect(response).to redirect_to(dashboard_path)
      end
    end

    context "when logged in as an evaluator" do
      before do
        create_and_log_in_user(role: "evaluator")
      end

      it "renders the index view with the correct header" do
        get evaluations_path

        expect(response).to have_http_status(:success)
        expect(response.body).to include("Evaluations")
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
  end

  # evaluation_path
  describe "GET /evaluations/:id" do
    context "when logged in as an evaluator" do
      it "allows me to view a draft evaluation I created"

      it "allows me to view a completed evaluation I created"

      it "does not allow me to view an evaluation I didn't create"
    end
  end

  # new_evaluator_submission_assignment_evaluation_path
  describe "GET /evaluator_submission_assignments/:evaluator_submission_assignment_id/evaluations/new" do
    context "when logged in as an evaluator" do
      let(:current_user) { create_user(role: "evaluator") }
      let(:evaluator_submission_assignment) { create(:evaluator_submission_assignment, user_id: current_user.id) }

      before { log_in_user(current_user) }

      it "takes me to the new evaluation page if I was assigned to the submission" do
        evaluation_form = create(:evaluation_form, phase: evaluator_submission_assignment.phase)

        get new_evaluator_submission_assignment_evaluation_path(
          evaluator_submission_assignment_id: evaluator_submission_assignment.id
        )

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

        get new_evaluator_submission_assignment_evaluation_path(
          evaluator_submission_assignment_id: evaluator_submission_assignment.id
        )

        expect(response).to redirect_to(evaluations_path)
        expect(flash[:alert]).to eq(I18n.t("evaluations.alerts.evaluator_submission_assignment_not_found"))
      end

      it "redirects me to my evaluations if the submission assignment was not found" do
        get new_evaluator_submission_assignment_evaluation_path(evaluator_submission_assignment_id: "missing")

        expect(response).to redirect_to(evaluations_path)
        expect(flash[:alert]).to eq(I18n.t("evaluations.alerts.evaluator_submission_assignment_not_found"))
      end

      it "redirects me to my evaluations if the submission assignment has no evaluation form" do
        # No evaluation form is currently created for the phase by default in the factory
        evaluator_submission_assignment = create(:evaluator_submission_assignment, user_id: current_user.id)

        get new_evaluator_submission_assignment_evaluation_path(
          evaluator_submission_assignment_id: evaluator_submission_assignment.id
        )
        expect(response).to redirect_to(evaluations_path)
      end
    end
  end

  # save_draft_evaluations_path
  describe "POST /evaluations/save_draft" do
    context "when logged in as an evaluator" do
      let(:current_user) { create_user(role: "evaluator") }

      before { log_in_user(current_user) }

      it "allows me to save a draft of my new evaluation to skip validations and not set completed_at" do
        evaluator_submission_assignment = create(:evaluator_submission_assignment, user_id: current_user.id)
        evaluation_form = create(:evaluation_form, phase: evaluator_submission_assignment.phase)

        evaluation = build_evaluation(evaluator_submission_assignment)
        evaluation_params = build_evaluation_params(evaluation)

        # Nullify scores to test draft saving skipping validations
        evaluation_params[:evaluation_scores_attributes].each do |value|
          value[:score] = nil
          value[:comment] = nil
        end

        expect do
          post save_draft_evaluations_path, params: { evaluation: evaluation_params }
        end.to change { Evaluation.count }

        saved_evaluation = Evaluation.last

        expect(saved_evaluation.completed_at).to be_nil
        expect(saved_evaluation.evaluation_scores.count).to eq(evaluation_form.evaluation_criteria.count)
        saved_evaluation.evaluation_scores.each do |score|
          expect(score.score).to be_nil
          expect(score.comment).to be_nil
        end

        expect(response).to redirect_to(evaluations_path)
        expect(flash[:notice]).to eq(I18n.t('evaluations.notices.saved_draft'))
      end

      it "does not allow me to save a draft evaluation for a submission I'm not assigned to" do
        user = create(:user, :evaluator)
        evaluator_submission_assignment = create(:evaluator_submission_assignment, user_id: user.id)
        create(:evaluation_form, phase: evaluator_submission_assignment.phase)

        evaluation = build_evaluation(evaluator_submission_assignment)
        evaluation_params = build_evaluation_params(evaluation)

        # Nullify scores to test draft saving skipping validations
        evaluation_params[:evaluation_scores_attributes].each do |value|
          value[:score] = nil
          value[:comment] = nil
        end

        expect do
          post save_draft_evaluations_path, params: { evaluation: evaluation_params }
        end.not_to change { Evaluation.count }

        expect(response).to redirect_to(evaluations_path)
        expect(flash[:alert]).to eq(I18n.t("evaluations.alerts.unauthorized"))
      end

      it "renders new template if an association is missing" do
        evaluator_submission_assignment = create(:evaluator_submission_assignment, user_id: current_user.id)
        create(:evaluation_form, phase: evaluator_submission_assignment.phase)

        evaluation = build_evaluation(evaluator_submission_assignment)
        evaluation_params = build_evaluation_params(evaluation)

        post save_draft_evaluations_path, params: { evaluation: evaluation_params.merge({ evaluation_form_id: nil }) }

        expect(response).to render_template(:new)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(flash[:alert]).to match(I18n.t("evaluations.alerts.save_draft_error"))
      end
    end
  end

  # mark_complete_evaluations_path
  describe "POST /evaluations/mark_complete" do
    context "when logged in as an evaluator" do
      let(:current_user) { create_user(role: "evaluator") }

      before { log_in_user(current_user) }

      it "allows me to mark my new evaluation as complete" do
        evaluator_submission_assignment = create(:evaluator_submission_assignment, user_id: current_user.id)
        evaluation_form = create(:evaluation_form, phase: evaluator_submission_assignment.phase)

        evaluation = build_evaluation(evaluator_submission_assignment)
        evaluation_params = build_evaluation_params(evaluation)

        expect do
          post mark_complete_evaluations_path, params: { evaluation: evaluation_params }
        end.to change { Evaluation.count }

        saved_evaluation = Evaluation.last

        expect(saved_evaluation.completed_at).not_to be_nil
        expect(saved_evaluation.evaluation_scores.count).to eq(evaluation_form.evaluation_criteria.count)
        saved_evaluation.evaluation_scores.each do |score|
          expect(score.score).not_to be_nil
        end

        expect(response).to redirect_to(evaluations_path)
        expect(flash[:notice]).to eq(I18n.t("evaluations.notices.marked_complete"))
      end

      it "does not allow me to mark my new evaluation as complete if it fails validations" do
        evaluator_submission_assignment = create(:evaluator_submission_assignment, user_id: current_user.id)
        create(:evaluation_form, phase: evaluator_submission_assignment.phase)

        evaluation = build_evaluation(evaluator_submission_assignment)
        evaluation_params = build_evaluation_params(evaluation)

        # Nullify scores to test marking as complete fail validations
        evaluation_params[:evaluation_scores_attributes].each do |value|
          value[:score] = nil
          value[:comment] = nil
        end

        expect do
          post mark_complete_evaluations_path, params: { evaluation: evaluation_params }
        end.not_to change { Evaluation.count }

        failed_evaluation = assigns(:evaluation)

        expect(response).to render_template(:new)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(flash[:alert]).to match(I18n.t("evaluations.alerts.mark_complete_error",
                                              errors: failed_evaluation.errors.full_messages.to_sentence))
      end

      it "does not allow me to mark my new evaluation as complete for a submission I'm not assigned to" do
        user = create(:user, :evaluator)
        evaluator_submission_assignment = create(:evaluator_submission_assignment, user_id: user.id)
        create(:evaluation_form, phase: evaluator_submission_assignment.phase)

        evaluation = build_evaluation(evaluator_submission_assignment)
        evaluation_params = build_evaluation_params(evaluation)

        expect do
          post mark_complete_evaluations_path, params: { evaluation: evaluation_params }
        end.not_to change { Evaluation.count }

        expect(response).to redirect_to(evaluations_path)
        expect(flash[:alert]).to eq(I18n.t("evaluations.alerts.unauthorized"))
      end
    end
  end

  # edit_evaluation_path
  describe "GET /evaluations/:id/edit" do
    context "when logged in as an evaluator" do
      let(:current_user) { create_user(role: "evaluator") }

      before { log_in_user(current_user) }

      it "allows me to view an existing draft evaluation I created" do
        evaluator_submission_assignment = create(:evaluator_submission_assignment, user_id: current_user.id)
        evaluation_form = create(:evaluation_form, phase: evaluator_submission_assignment.phase)

        evaluation = create(:evaluation,
                            user: current_user,
                            evaluation_form: evaluation_form,
                            submission: evaluator_submission_assignment.submission,
                            evaluator_submission_assignment: evaluator_submission_assignment)

        get edit_evaluation_path(evaluation)

        evaluation = assigns(:evaluation)

        expect(evaluation.user_id).to eq(current_user.id)
        expect(evaluation.evaluation_form_id).to eq(evaluation_form.id)
        expect(evaluation.submission_id).to eq(evaluator_submission_assignment.submission_id)
        expect(evaluation.evaluator_submission_assignment_id).to eq(evaluator_submission_assignment.id)

        criteria_ids = evaluation.evaluation_form.evaluation_criteria.pluck(:id)
        score_criteria_ids = evaluation.evaluation_scores.map(&:evaluation_criterion_id)

        expect(score_criteria_ids).to match_array(criteria_ids)
      end

      it "allows me to view an existing complete evaluation I created" do
        evaluator_submission_assignment = create(:evaluator_submission_assignment, user_id: current_user.id)
        evaluation_form = create(:evaluation_form, phase: evaluator_submission_assignment.phase)

        evaluation = create(:evaluation,
                            user: current_user,
                            evaluation_form: evaluation_form,
                            submission: evaluator_submission_assignment.submission,
                            evaluator_submission_assignment: evaluator_submission_assignment,
                            completed_at: Time.current)

        get edit_evaluation_path(evaluation)

        evaluation = assigns(:evaluation)

        expect(evaluation.user_id).to eq(current_user.id)
        expect(evaluation.evaluation_form_id).to eq(evaluation_form.id)
        expect(evaluation.submission_id).to eq(evaluator_submission_assignment.submission_id)
        expect(evaluation.evaluator_submission_assignment_id).to eq(evaluator_submission_assignment.id)

        criteria_ids = evaluation.evaluation_form.evaluation_criteria.pluck(:id)
        score_criteria_ids = evaluation.evaluation_scores.map(&:evaluation_criterion_id)

        expect(score_criteria_ids).to match_array(criteria_ids)
      end

      it "redirects me if I try to view an evaluation I did not create" do
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

  # save_draft_evaluation_path
  describe "PATCH /evaluations/:id/save_draft" do
    context "when logged in as an evaluator" do
      let(:current_user) { create_user(role: "evaluator") }

      before { log_in_user(current_user) }

      it "allows me to save a draft of my existing evaluation to skip validations and not set completed_at", bullet: :skip do
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
        evaluation_params[:evaluation_scores_attributes].each do |value|
          value[:score] = nil
          value[:comment] = nil
        end

        patch save_draft_evaluation_path(evaluation, params: { evaluation: evaluation_params })

        updated_evaluation = assigns(:evaluation)

        expect(updated_evaluation).to be_persisted
        expect(updated_evaluation.additional_comments).to eq("Test")

        expect(updated_evaluation.errors).to be_empty
        expect(updated_evaluation.completed_at).to be_nil

        expect(response).to redirect_to(evaluations_path)
        expect(flash[:notice]).to include(I18n.t("evaluations.notices.saved_draft"))
      end

      it "does not allow me to save a draft of an evaluation I did not create", bullet: :skip do
        user = create(:user, :evaluator)
        evaluator_submission_assignment = create(:evaluator_submission_assignment, user_id: user.id)
        evaluation_form = create(:evaluation_form, phase: evaluator_submission_assignment.phase)

        evaluation = create(:evaluation,
                            user: user,
                            evaluation_form: evaluation_form,
                            submission: evaluator_submission_assignment.submission,
                            evaluator_submission_assignment: evaluator_submission_assignment)

        evaluation_params = { additional_comments: "Test" }

        patch save_draft_evaluation_path(evaluation, params: { evaluation: evaluation_params })

        expect(response).to redirect_to(evaluations_path)
        expect(flash[:alert]).to eq(I18n.t("evaluations.alerts.unauthorized"))
      end
    end
  end

  # mark_complete_evaluation_path
  describe "PATCH /evaluations/:id/mark_complete" do
    context "when logged in as an evaluator" do
      let(:current_user) { create_user(role: "evaluator") }

      before { log_in_user(current_user) }

      it "allows me to mark my existing evaluation as complete", bullet: :skip do
        evaluator_submission_assignment = create(:evaluator_submission_assignment, user_id: current_user.id)
        evaluation_form = create(:evaluation_form, phase: evaluator_submission_assignment.phase)

        evaluation = create(:evaluation,
                            user: current_user,
                            evaluation_form: evaluation_form,
                            submission: evaluator_submission_assignment.submission,
                            evaluator_submission_assignment: evaluator_submission_assignment)

        evaluation_params = { additional_comments: "Test" }

        patch mark_complete_evaluation_path(evaluation, params: { evaluation: evaluation_params })

        updated_evaluation = assigns(:evaluation)

        expect(updated_evaluation).to be_persisted
        expect(updated_evaluation.additional_comments).to eq("Test")

        expect(updated_evaluation.errors).to be_empty
        expect(updated_evaluation.completed_at).not_to be_nil

        expect(response).to redirect_to(evaluations_path)
        expect(flash[:notice]).to include(I18n.t("evaluations.notices.marked_complete"))
      end

      # TODO: Needs fix
      it "does not allow me to mark my existing evaluation as complete if it fails validations", bullet: :skip do
        evaluator_submission_assignment = create(:evaluator_submission_assignment, user_id: current_user.id)
        evaluation_form = create(:evaluation_form, phase: evaluator_submission_assignment.phase)

        evaluation = create(:evaluation,
                            user: current_user,
                            evaluation_form: evaluation_form,
                            submission: evaluator_submission_assignment.submission,
                            evaluator_submission_assignment: evaluator_submission_assignment)

        evaluation_params = build_patch_evaluation_params(evaluation)

        # Nullify scores to test draft saving skipping validations
        evaluation_params[:evaluation_scores_attributes].each do |value|
          value[:score] = nil
          value[:comment] = nil
        end

        patch mark_complete_evaluation_path(evaluation, params: { evaluation: evaluation_params })

        failed_evaluation = assigns(:evaluation)
        evaluation_record = Evaluation.find_by(id: failed_evaluation.id)

        expect(failed_evaluation.completed_at).to be_nil
        expect(evaluation_record.completed_at).to be_nil

        expect(response).to render_template(:edit)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(flash[:alert]).to match(I18n.t("evaluations.alerts.mark_complete_error",
                                              errors: failed_evaluation.errors.full_messages.to_sentence))
      end

      it "does not allow me to mark an evaluation I did not create as complete", bullet: :skip do
        user = create(:user, :evaluator)
        evaluator_submission_assignment = create(:evaluator_submission_assignment, user_id: user.id)
        evaluation_form = create(:evaluation_form, phase: evaluator_submission_assignment.phase)

        evaluation = create(:evaluation,
                            user: user,
                            evaluation_form: evaluation_form,
                            submission: evaluator_submission_assignment.submission,
                            evaluator_submission_assignment: evaluator_submission_assignment)

        evaluation_params = { additional_comments: "Test" }

        patch mark_complete_evaluation_path(evaluation, params: { evaluation: evaluation_params })

        expect(response).to redirect_to(evaluations_path)
        expect(flash[:alert]).to eq(I18n.t("evaluations.alerts.unauthorized"))
      end
    end
  end

  def build_evaluation(evaluator_submission_assignment)
    user = evaluator_submission_assignment.evaluator
    evaluation_form = evaluator_submission_assignment.phase.evaluation_form
    submission = evaluator_submission_assignment.submission

    evaluation = Evaluation.new(
      user: user,
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
      user_id: evaluation.user_id,
      evaluator_submission_assignment_id: evaluation.evaluator_submission_assignment_id,
      submission_id: evaluation.evaluator_submission_assignment.submission_id,
      evaluation_form_id: evaluation.evaluation_form_id,
      evaluation_scores_attributes: evaluation.evaluation_scores.map do |score|
        {
          evaluation_criterion_id: score.evaluation_criterion_id,
          score: valid_score_for_criterion(score),
          comment: Faker::Lorem.sentence
        }
      end
    }
  end

  def build_patch_evaluation_params(evaluation)
    {
      additional_comments: evaluation.additional_comments,
      revision_comments: evaluation.revision_comments,
      evaluation_scores_attributes: evaluation.evaluation_scores.map do |score|
        {
          id: score.id,
          evaluation_criterion_id: score.evaluation_criterion_id,
          score: valid_score_for_criterion(score),
          comment: Faker::Lorem.sentence
        }
      end
    }
  end
end
