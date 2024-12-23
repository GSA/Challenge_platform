# frozen_string_literal: true

# Controller for challenge submissions CRUD actions.
class SubmissionsController < ApplicationController
  before_action -> { authorize_user('challenge_manager') }
  before_action :set_submission, only: [:show, :update]

  def show; end

  def update
    if @submission.update!(submission_params)
      flash.now[:success] = I18n.t("submission_updated")
      render :show, submission: @submission
    else
      render :show, status: :unprocessable_entity, submission: @submission
    end
  end

  private

  def submission_params
    params.require(:submission).permit(:comments, :judging_status)
  end

  # User access enforced by role
  def set_submission
    @submission = Submission.by_user(current_user).find(params[:id])
  end
end
