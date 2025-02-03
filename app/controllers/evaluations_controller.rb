# frozen_string_literal: true

# TODO: Reenable rubocop after refactor/shortening controller code or moving some functionality into service
# rubocop:disable Metrics/ClassLength

# Controller for evaluations CRUD actions.
class EvaluationsController < ApplicationController
  before_action -> { authorize_user('evaluator') }
  before_action :set_evaluation_and_submission_assignment, only: %i[create update]
  before_action :set_phase, only: [:submissions]
  before_action :set_submission, only: [:new]

  def index
    @phases = Phase.joins(:evaluator_submission_assignments).
      where(evaluator_submission_assignments: {
              user_id: current_user.id,
              status: [:assigned, :recused]
            }).
      includes(:challenge, :evaluation_form).
      distinct
  end

  def submissions
    @assigned_submissions = @phase.evaluator_submission_assignments.
      where(evaluator: current_user).
      where(status: %i[assigned recused]).
      includes(:submission, :evaluation).
      ordered_by_status

    @submissions_count = helpers.calculate_submissions_count(@assigned_submissions)
  end

  def new
    @evaluator_submission_assignment = find_evaluator_submission_assignment

    if @evaluator_submission_assignment.nil? || !can_access_evaluation?
      return redirect_to evaluations_path, alert: I18n.t("evaluations.alerts.evaluator_submission_assignment_not_found")
    end

    @evaluation_form = EvaluationForm.find_by(phase: @evaluator_submission_assignment.phase)

    if @evaluation_form.nil?
      return redirect_to evaluations_path, alert: I18n.t("evaluations.alerts.evaluation_form_not_found")
    end

    build_evaluation

    render :new
  end

  def edit
    @evaluation = Evaluation.includes([evaluation_scores: :evaluation_criterion]).find_by(id: params[:id])
    @evaluator_submission_assignment = find_evaluator_submission_assignment
    return unauthorized_redirect unless can_access_evaluation?

    @submission = @evaluation.submission

    render :edit
  end

  def create
    if save_evaluation
      flash[:notice] =
        if params[:subaction] == "mark_complete"
          I18n.t("evaluations.notices.marked_complete")
        else
          I18n.t("evaluations.notices.saved_draft")
        end

      redirect_to submissions_evaluation_path(@evaluation.submission.phase_id)
    else
      @submission = @evaluation.submission
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if save_evaluation
      flash[:notice] =
        if params[:subaction] == "mark_complete"
          I18n.t("evaluations.notices.marked_complete")
        else
          I18n.t("evaluations.notices.saved_draft")
        end

      redirect_to submissions_evaluation_path(@evaluation.submission.phase_id)
    else
      @submission = @evaluation.submission
      render :edit, status: :unprocessable_entity
    end
  end

  def recuse
    @evaluator_submission_assignment = find_evaluator_submission_assignment
    return unauthorized_redirect unless can_access_evaluation?

    begin
      if recuse_evaluator
        destroy_recused_evaluation
        flash[:notice] = I18n.t("evaluations.recusal.success")
        redirect_to submissions_evaluation_path(@evaluator_submission_assignment.phase)
      else
        handle_recusal_failure
      end
    rescue ActiveRecord::RecordInvalid => e
      handle_recusal_failure
    end
  end

  private

  def save_evaluation
    if params[:subaction] == "mark_complete"
      @evaluation.completed_at = Time.current
      unless @evaluation.save
        # Reset completed at if validation fails
        @evaluation.completed_at = nil
        return false
      end
    else
      @evaluation.completed_at = nil
      @evaluation.save(validate: false)
    end

    true
  end

  def set_evaluation_and_submission_assignment
    @evaluation = find_or_initialize_evaluation
    @evaluation.assign_attributes(evaluation_params)

    @evaluator_submission_assignment = find_evaluator_submission_assignment

    unauthorized_redirect unless can_access_evaluation?
  end

  def set_phase
    @phase = Phase.joins(:challenge_phases_evaluators).
      where(challenge_phases_evaluators: { user_id: current_user.id }).
      find(params[:id])
    @challenge = @phase.challenge
  end

  def set_submission
    @submission = Submission.find_by(id: params[:submission_id])
  end

  def find_or_initialize_evaluation
    if params[:id]
      Evaluation.includes([evaluation_scores: :evaluation_criterion]).find(params[:id])
    else
      Evaluation.new(user_id: current_user.id)
    end
  end

  def find_evaluator_submission_assignment
    return @evaluation.evaluator_submission_assignment if @evaluation&.evaluator_submission_assignment.present?

    EvaluatorSubmissionAssignment.find_by(submission_id: params[:submission_id], user_id: current_user.id)
  end

  def can_access_evaluation?
    @evaluator_submission_assignment && @evaluator_submission_assignment.user_id == current_user.id
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

  def recuse_evaluator
    @evaluator_submission_assignment&.update(status: :recused)
  end

  def destroy_recused_evaluation
    @evaluator_submission_assignment.evaluation&.destroy!
  end

  # Redirect Helpers
  def unauthorized_redirect
    redirect_to evaluations_path, alert: I18n.t("evaluations.alerts.unauthorized")
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
        id evaluation_criterion_id
        score score_override
        comment comment_override
      ]
    )
  end

  def handle_recusal_failure
    flash[:alert] = I18n.t("evaluations.recusal.failure")
    redirect_to submissions_evaluation_path(@evaluator_submission_assignment.phase)
  end
end
# TODO: Remove this after above refactor
# rubocop:enable Metrics/ClassLength
