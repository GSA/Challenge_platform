# frozen_string_literal: true

# Controller for challenge submissions CRUD actions.
class SubmissionsController < ApplicationController
  before_action -> { authorize_user('challenge_manager') }
  before_action :set_submission, only: [:show, :update]

  def show; end

  def update
    respond_to do |format|
      if @submission.update(submission_params)
        format.html do
          flash[:success] = I18n.t("comments_saved")
          redirect_to submission_path(@submission.phase)
        end
        format.json { render json: { submission: @submission } }
      else
        format.html { render :show }
        format.json { render json: { errors: @submission.errors }, status: :unprocessable_entity }
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
end
