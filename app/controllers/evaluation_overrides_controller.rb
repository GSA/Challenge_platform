# frozen_string_literal: true

# Controller for evaluations CRUD actions.
class EvaluationOverridesController < ApplicationController
  before_action -> { authorize_user('challenge_manager') }
  before_action :set_instance_variables
  before_action :ensure_evaluation_completed_and_authorized

  def show; end

  def update
    if @evaluation.revisable? && @evaluation.update(evaluation_params)
      flash[:custom_success_heading] = I18n.t("evaluation_overrides.success.heading")
      flash[:custom_success_description] = I18n.t("evaluation_overrides.success.description")

      redirect_to @return_path
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def set_instance_variables
    @evaluation = Evaluation.includes([evaluation_scores: [evaluation_criterion: :evaluation_form]]).
      find_by(id: params[:id])

    return redirect_to dashboard_path, alert: I18n.t("evaluation_overrides.alerts.not_found") unless @evaluation

    @submission = @evaluation.submission
    @phase = @submission.phase
    @evaluator = @evaluation.user
    @return_path = submission_path(@submission)
  end

  def ensure_evaluation_completed_and_authorized
    return if @evaluation.completed_at.present? &&
              current_user.challenge_manager_challenges.exists?(id: @evaluation.submission.challenge_id)

    redirect_to @return_path, alert: I18n.t("evaluation_overrides.alerts.not_found")
  end

  def evaluation_params
    normalize_evaluation_scores_keys!

    params.require(:evaluation).permit(:revision_comments, evaluation_scores_attributes: %i[
                                         id score_override comment_override
                                       ])
  end

  # Normalize random hex keys to integer indexes rails understands for nested_attributes
  def normalize_evaluation_scores_keys!
    return if params.dig(:evaluation, :evaluation_scores_attributes).blank?

    params[:evaluation][:evaluation_scores_attributes] =
      params[:evaluation][:evaluation_scores_attributes].transform_keys.with_index { |_key, index| index.to_s }
  end
end
