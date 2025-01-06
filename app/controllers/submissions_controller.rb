# frozen_string_literal: true

# Controller for challenge submissions CRUD actions.
class SubmissionsController < ApplicationController
  before_action -> { authorize_user('challenge_manager') }
  before_action :set_submission, only: [:show, :update]

  def show; end

  def update
    respond_to do |format|
      if @submission.update(submission_params)
        handle_successful_update(format)
      else
        handle_failed_update(format)
      end
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

  def handle_successful_update(format)
    format.html do
      flash[:success] = I18n.t("submission_updated")
      redirect_to submission_path(@submission)
    end
    format.json { render json: { submission: @submission } }
  end

  def handle_failed_update(format)
    format.html { render :show }
    format.json { render json: { errors: @submission.errors }, status: :unprocessable_entity }
  end
end
