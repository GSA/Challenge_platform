# frozen_string_literal: true

# Controller for challenge submissions CRUD actions.
class SubmissionsController < ApplicationController
  before_action -> { authorize_user('challenge_manager') }
  before_action :set_submission, only: [:show, :update]

  def show; end

  def update
    if params[:submission][:judging_status].present?
      handle_judging_status_update
    else
      handle_comments_update
    end
  end

  private

  def handle_judging_status_update
    unless valid_status_change?
      return respond_with_error
    end

    if @submission.update(submission_params)
      respond_with_success
    else
      respond_with_error
    end
  end

  def handle_comments_update
    if @submission.update!(submission_params)
      flash.now[:success] = I18n.t("comments_saved")
      render :show, submission: @submission
    else
      render :show, status: :unprocessable_entity, submission: @submission
    end
  end

  def valid_status_change?
    new_status = params.dig(:submission, :judging_status)
    current_status = @submission.judging_status

    if new_status == 'selected' && current_status == 'not_selected' && @submission.eligibility_checkbox_disabled?
      return false
    end

    if new_status == 'winner' && (!@submission.eligible_for_evaluation? || @submission.advancement_checkbox_disabled?)
      return false
    end

    true
  end

  def respond_with_success
    respond_to do |format|
      format.html { redirect_to submissions_phase_path(@submission.phase) }
      format.json { render json: { success: true }, status: :ok }
    end
  end

  def respond_with_error
    respond_to do |format|
      format.html { redirect_to submissions_phase_path(@submission.phase) }
      format.json { render json: { success: false }, status: :unprocessable_entity }
    end
  end

  def submission_params
    params.require(:submission).permit(:comments, :judging_status)
  end

  # User access enforced by role
  def set_submission
    @submission = Submission.by_user(current_user).find(params[:id])
  end
end
