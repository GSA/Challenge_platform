# frozen_string_literal: true

# Controller for evaluations CRUD actions.
# TODO: Needs to be simplified and made shorter for Rubocop
class EvaluationsController < ApplicationController
  before_action -> { authorize_user('evaluator') }

  def index; end

  def show; end

  # TODO: This should also prevent any creation if their status is recused?
  def new
    @evaluator_submission_assignment = find_evaluator_submission_assignment

    # TODO: Fine to return a not found to prevent gathering info from alert messages?
    if @evaluator_submission_assignment.nil? || !can_access_evaluation?
      return redirect_to evaluations_path, alert: I18n.t("evaluations.alerts.evaluator_submission_assignment_not_found")
    end

    @evaluation_form = find_evaluation_form

    if @evaluation_form.nil?
      return redirect_to evaluations_path, alert: I18n.t("evaluations.alerts.evaluation_form_not_found")
    end

    build_evaluation

    render :new
  end

  def edit
    @evaluation = Evaluation.find(params[:id])
    return unauthorized_redirect unless can_access_evaluation?

    render :edit
  end

  def save_draft
    @evaluation = find_or_initialize_evaluation
    @evaluation.assign_attributes(evaluation_params)
    @evaluation.completed_at = nil

    @evaluator_submission_assignment = @evaluation.evaluator_submission_assignment

    return unauthorized_redirect unless can_access_evaluation?

    begin
      @evaluation.save(validate: false)
      handle_save_draft_success
    rescue ActiveRecord::RecordInvalid, ActiveRecord::NotNullViolation
      handle_save_draft_failure
    end
  end

  def mark_complete
    @evaluation = find_or_initialize_evaluation
    @evaluation.assign_attributes(evaluation_params)
    @evaluation.completed_at = Time.current

    @evaluator_submission_assignment = @evaluation.evaluator_submission_assignment

    # Check if the current user can access the evaluation
    return unauthorized_redirect unless can_access_evaluation?

    # TODO: Set total_score here when the evaluation is marked complete

    if @evaluation.update(evaluation_params)
      handle_mark_complete_success
    else
      handle_mark_complete_failure
    end
  end

  private

  def unauthorized_redirect
    redirect_to evaluations_path, alert: I18n.t("evaluations.alerts.unauthorized")
  end

  def handle_save_draft_success
    flash[:notice] = I18n.t("evaluations.notices.saved_draft")
    redirect_to evaluations_path
  end

  def handle_save_draft_failure
    flash.now[:alert] =
      I18n.t("evaluations.alerts.save_draft_error", errors: @evaluation.errors.full_messages.to_sentence)

    if @evaluation.new_record?
      render :new, status: :unprocessable_entity
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def handle_mark_complete_success
    flash[:notice] = I18n.t("evaluations.notices.marked_complete")
    redirect_to evaluations_path
  end

  def handle_mark_complete_failure
    flash.now[:alert] =
      I18n.t("evaluations.alerts.mark_complete_error", errors: @evaluation.errors.full_messages.to_sentence)

    if @evaluation.new_record?
      render :new, status: :unprocessable_entity
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def find_or_initialize_evaluation
    if params[:id]
      Evaluation.find(params[:id])
    else
      Evaluation.new
    end
  end

  def find_evaluator_submission_assignment
    EvaluatorSubmissionAssignment.find_by(id: params[:evaluator_submission_assignment_id])
  end

  def can_access_evaluation?
    (@evaluator_submission_assignment && @evaluator_submission_assignment.user_id == current_user.id) ||
      (@evaluation && @evaluation.user_id == current_user.id)
  end

  def find_evaluation_form
    @phase = @evaluator_submission_assignment.phase
    EvaluationForm.find_by(phase: @phase)
  end

  def build_evaluation
    @submission = @evaluator_submission_assignment.submission
    @evaluation = Evaluation.new(
      user: current_user,
      evaluation_form: @evaluation_form,
      submission: @submission,
      evaluator_submission_assignment: @evaluator_submission_assignment
    )

    @evaluation_form.evaluation_criteria.each do |criterion|
      @evaluation.evaluation_scores.build(evaluation_criterion: criterion)
    end
  end

  def evaluation_params
    params.require(:evaluation).permit(
      :user_id,
      :evaluator_submission_assignment_id,
      :submission_id,
      :evaluation_form_id,
      :additional_comments,
      :revision_comments,
      evaluation_scores_attributes: %i[
        evaluation_criterion_id
        score score_override
        comment comment_override
      ]
    )
  end
end
