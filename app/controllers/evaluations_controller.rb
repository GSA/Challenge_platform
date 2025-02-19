# frozen_string_literal: true

# Controller for evaluations CRUD actions.
# rubocop:disable Metrics/ClassLength
class EvaluationsController < ApplicationController
  before_action -> { authorize_user('evaluator') }
  before_action :set_evaluation_and_submission_assignment, only: %i[create update]

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
    @phase = Phase.joins(:challenge_phases_evaluators).
      where(challenge_phases_evaluators: { user_id: current_user.id }).
      find(params[:id])

    @challenge = @phase.challenge

    @assigned_submissions = @phase.evaluator_submission_assignments.
      where(evaluator: current_user).
      where(status: %i[assigned recused]).
      includes(:submission, :evaluation).
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
    @evaluation = Evaluation.includes([evaluation_scores: :evaluation_criterion]).find_by(id: params[:id])
    fetch_evaluator_submission_assignment
    return unauthorized_redirect unless can_access_evaluation?

    render :show
  end

  def create
    if save_evaluation
      flash[:notice] =
        if params[:subaction] == "mark_complete"
          I18n.t("evaluations.notices.marked_complete")
        else
          I18n.t("evaluations.notices.saved_draft")
        end

      redirect_to confirmation_evaluation_path(@evaluation, subaction: params[:subaction])
    else
      render :show, status: :unprocessable_entity
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

      redirect_to confirmation_evaluation_path(@evaluation, subaction: params[:subaction])
    else
      render :show, status: :unprocessable_entity
    end
  end

  def recuse
    @evaluator_submission_assignment =
      current_user.evaluator_submission_assignments.where(submission_id: params[:submission_id]).first

    if EvaluatorRecusalService.new(@evaluator_submission_assignment).call
      send_recusal_notification

      flash[:notice] = I18n.t("evaluations.recusal.success")
      redirect_to submissions_evaluation_path(@evaluator_submission_assignment.phase), status: :see_other
    else
      unauthorized_redirect
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
    fetch_evaluator_submission_assignment

    unauthorized_redirect unless can_access_evaluation?
  end

  def find_or_initialize_evaluation
    if params[:id]
      Evaluation.includes([evaluation_scores: :evaluation_criterion]).find(params[:id])
    else
      Evaluation.new(user_id: current_user.id)
    end
  end

  def fetch_evaluator_submission_assignment
    @evaluator_submission_assignment =
      @evaluation&.evaluator_submission_assignment ||
      EvaluatorSubmissionAssignment.find_by(submission_id: params[:submission_id], user_id: current_user.id)
    @submission = @evaluator_submission_assignment&.submission
    @evaluator_submission_assignment
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

  def send_recusal_notification
    NotificationMailer.recusal(@evaluator_submission_assignment).deliver_now
  end

  # Redirect Helpers
  def unauthorized_redirect
    redirect_to evaluations_path, alert: I18n.t("evaluations.alerts.unauthorized")
  end

  def evaluation_params
    normalize_evaluation_scores_keys!

    permitted_attributes = if @evaluation&.completed_at.present?
                             %i[revision_comments] + [{ evaluation_scores_attributes: %i[id score_override
                                                                                         comment_override] }]
                           else
                             %i[user_id evaluator_submission_assignment_id submission_id evaluation_form_id
                                additional_comments revision_comments] +
                               [{ evaluation_scores_attributes: %i[id evaluation_criterion_id score score_override
                                                                   comment comment_override] }]
                           end

    params.require(:evaluation).permit(*permitted_attributes)
  end

  # Normalize random hex keys to integer indexes rails understands for nested_attributes
  def normalize_evaluation_scores_keys!
    return if params.dig(:evaluation, :evaluation_scores_attributes).blank?

    params[:evaluation][:evaluation_scores_attributes] =
      params[:evaluation][:evaluation_scores_attributes].transform_keys.with_index { |_key, index| index.to_s }
  end
end
# rubocop:enable Metrics/ClassLength
