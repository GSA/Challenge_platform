# frozen_string_literal: true

# Controller for evaluations CRUD actions.
class EvaluationOverridesController < ApplicationController
  before_action -> { authorize_user('challenge_manager') }
  before_action :set_instance_variables

  # TODO: Redirect if not completed evaluation or not correct challenge manager
  # TODO: Fix back button and evaluator name links
  def show; end

  # TODO: Fix redirect
  def update
    if @evaluation.update(evaluation_params)
      render :show, notice: "Revision submitted"
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def set_instance_variables
    @evaluation = Evaluation.includes([evaluation_scores: :evaluation_criterion]).find_by(id: params[:id])
    @submission = @evaluation.submission
    @evaluator = @evaluation.user
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
