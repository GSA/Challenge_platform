# frozen_string_literal: true

# Controller for evaluations CRUD actions.
class EvaluationsController < ApplicationController
  before_action -> { authorize_user('evaluator') }
  before_action :set_evaluation_and_submission_assignment, only: %i[save_draft mark_complete]

  def index; end

  def show; end

  def new
    @evaluator_submission_assignment = find_evaluator_submission_assignment

    if @evaluator_submission_assignment.nil? || !can_access_evaluation?
      return redirect_to evaluations_path, alert: I18n.t("evaluations.alerts.evaluator_submission_assignment_not_found")
    end

    phase = @evaluator_submission_assignment.phase
    @evaluation_form = EvaluationForm.find_by(phase: phase)

    if @evaluation_form.nil?
      return redirect_to evaluations_path, alert: I18n.t("evaluations.alerts.evaluation_form_not_found")
    end

    build_evaluation

    render :new
  end

  def edit
    @evaluation = Evaluation.find_by(id: params[:id])
    return unauthorized_redirect unless can_access_evaluation?

    render :edit
  end

  def save_draft
    @evaluation.completed_at = nil
    @evaluation.save(validate: false)

    flash[:notice] = I18n.t("evaluations.notices.saved_draft")
    redirect_to evaluations_path
  rescue ActiveRecord::RecordInvalid, ActiveRecord::NotNullViolation
    handle_save_draft_failure
  end

  def mark_complete
    @evaluation.completed_at = Time.current

    if @evaluation.save
      flash[:notice] = I18n.t("evaluations.notices.marked_complete")
      redirect_to evaluations_path
    else
      @evaluation.completed_at = nil
      handle_mark_complete_failure
    end
  end

  private

  def set_evaluation_and_submission_assignment
    @evaluation = find_or_initialize_evaluation
    @evaluation.assign_attributes(evaluation_params)

    @evaluator_submission_assignment = find_evaluator_submission_assignment

    unauthorized_redirect unless can_access_evaluation?
  end

  def find_or_initialize_evaluation
    if params[:id]
      Evaluation.includes([:evaluation_criteria]).find(params[:id])
    else
      Evaluation.new
    end
  end

  def find_evaluator_submission_assignment
    return @evaluation.evaluator_submission_assignment if @evaluation&.evaluator_submission_assignment.present?

    EvaluatorSubmissionAssignment.find_by(id: params[:evaluator_submission_assignment_id])
  end

  def can_access_evaluation?
    (@evaluator_submission_assignment && @evaluator_submission_assignment.user_id == current_user.id) ||
      (@evaluation && @evaluation.user_id == current_user.id)
  end

  def build_evaluation
    @evaluation = Evaluation.new(
      user: current_user,
      evaluation_form: @evaluation_form,
      evaluator_submission_assignment: @evaluator_submission_assignment,
      submission: @evaluator_submission_assignment.submission
    )

    @evaluation_form.evaluation_criteria.each do |criterion|
      @evaluation.evaluation_scores.build(evaluation_criterion: criterion)
    end
  end

  # Redirect Helpers
  def unauthorized_redirect
    redirect_to evaluations_path, alert: I18n.t("evaluations.alerts.unauthorized")
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

  def handle_mark_complete_failure
    flash.now[:alert] =
      I18n.t("evaluations.alerts.mark_complete_error", errors: @evaluation.errors.full_messages.to_sentence)

    if @evaluation.new_record?
      render :new, status: :unprocessable_entity
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # Params
  def evaluation_params
    params.require(:evaluation).permit(
      :user_id,
      :evaluator_submission_assignment_id,
      :submission_id,
      :evaluation_form_id,
      :additional_comments,
      :revision_comments,
      evaluation_scores_attributes: %i[
        id evaluation_criterion_id
        score score_override
        comment comment_override
      ]
    )
  end
end
