# frozen_string_literal: true

# This service handles evaluation initialization
class EvaluationInitService
  def initialize(params, current_user)
    @params = params
    @current_user = current_user
  end

  def call
    find_or_initialize_evaluation
  end

  private

  def find_or_initialize_evaluation
    @evaluation =
      if @params[:id]
        Evaluation.includes([evaluation_scores: :evaluation_criterion]).find(@params[:id])
      else
        Evaluation.new(user_id: @current_user.id)
      end

    @evaluation.assign_attributes(evaluation_params)
    @evaluation
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

    @params.require(:evaluation).permit(*permitted_attributes)
  end

  # Normalize random hex keys to integer indexes rails understands for nested_attributes
  def normalize_evaluation_scores_keys!
    return if @params.dig(:evaluation, :evaluation_scores_attributes).blank?

    @params[:evaluation][:evaluation_scores_attributes] =
      @params[:evaluation][:evaluation_scores_attributes].transform_keys.with_index { |_key, index| index.to_s }
  end
end
