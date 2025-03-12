# frozen_string_literal: true

# Controller for evaluations CRUD actions.
class EvaluationsController < ApplicationController
  before_action -> { authorize_user('evaluator') }
  before_action -> { authorize_active_evaluators }
  before_action :set_evaluation_and_submission_assignment, only: %i[create update]

  def index
    @phases = Phase.joins(:evaluator_submission_assignments).
      where(evaluator_submission_assignments: {
              user_id: current_user.id,
              status: [:assigned, :recused]
            }).includes(:challenge, :evaluation_form).distinct
  end

  def submissions
    @phase = Phase.joins(:challenge_phases_evaluators).
      where(challenge_phases_evaluators: { user_id: current_user.id }).find(params[:id])

    @challenge = @phase.challenge

    @assigned_submissions = @phase.evaluator_submission_assignments.
      where(evaluator: current_user).where(status: %i[assigned recused]).
      includes(submission: {}, evaluation: :evaluation_scores).
      ordered_by_status

    @submissions_count = helpers.calculate_submissions_count(@assigned_submissions)
  end

  def confirmation
    @evaluation = Evaluation.find(params[:id])
    @subaction = params[:subaction]
  end

  def new
    fetch_evaluator_submission_assignment

    if @evaluator_submission_assignment.nil? || !can_access_evaluation?
      return redirect_to evaluations_path, alert: I18n.t("evaluations.alerts.evaluator_submission_assignment_not_found")
    end

    @evaluation_form = EvaluationForm.find_by(phase: @evaluator_submission_assignment.phase)

    if @evaluation_form.nil?
      return redirect_to evaluations_path, alert: I18n.t("evaluations.alerts.evaluation_form_not_found")
    end

    build_evaluation

    render :show
  end

  def edit
    @evaluation = Evaluation.includes([evaluation_scores: [evaluation_criterion: :evaluation_form]]).find(params[:id])
    fetch_evaluator_submission_assignment

    return unauthorized_redirect unless can_access_evaluation?

    render :show
  end

  def create
    if EvaluationSavingService.new(@evaluation, params[:subaction]).call
      custom_success_redirect
    else
      render :show, status: :unprocessable_entity
    end
  end

  def update
    if EvaluationSavingService.new(@evaluation, params[:subaction]).call
      custom_success_redirect
    else
      render :show, status: :unprocessable_entity
    end
  end

  def recuse
    @evaluator_submission_assignment =
      current_user.evaluator_submission_assignments.where(submission_id: params[:submission_id]).first

    if EvaluatorRecusalService.new(@evaluator_submission_assignment).call
      send_recusal_notification
      custom_recusal_redirect
    else
      unauthorized_redirect
    end
  end

  private

  def set_evaluation_and_submission_assignment
    @evaluation = EvaluationInitService.new(params, current_user).call
    fetch_evaluator_submission_assignment

    unauthorized_redirect unless can_access_evaluation?
  end

  def fetch_evaluator_submission_assignment
    @evaluator_submission_assignment =
      @evaluation&.evaluator_submission_assignment ||
      EvaluatorSubmissionAssignment.find_by(submission_id: params[:submission_id], user_id: current_user.id)
    @submission = @evaluator_submission_assignment&.submission
    @evaluator_submission_assignment
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

  def send_recusal_notification
    NotificationMailer.recusal(@evaluator_submission_assignment).deliver_now
  end

  # Auth Helpers
  def can_access_evaluation?
    @evaluator_submission_assignment && @evaluator_submission_assignment.user_id == current_user.id
  end

  # Redirect Helpers
  def unauthorized_redirect
    redirect_to evaluations_path, alert: I18n.t("evaluations.alerts.unauthorized")
  end

  def custom_success_redirect
    flash[:custom_success_heading] = I18n.t("evaluations.success.#{params[:subaction]}_heading")
    flash[:custom_success_description] = I18n.t("evaluations.success.#{params[:subaction]}_description")

    redirect_to submissions_evaluation_path(@evaluator_submission_assignment.phase), status: :see_other
  end

  def custom_recusal_redirect
    flash[:custom_success_heading] = I18n.t("evaluations.success.evaluator_recusal_heading")
    flash[:custom_success_description] = I18n.t("evaluations.success.evaluator_recusal_description")

    redirect_to submissions_evaluation_path(@evaluator_submission_assignment.phase)
  end
end
