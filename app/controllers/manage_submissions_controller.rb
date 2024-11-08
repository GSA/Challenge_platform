# frozen_string_literal: true

class ManageSubmissionsController < ApplicationController
  before_action -> { authorize_user('challenge_manager') }
  def index
    @challenges = current_user.challenge_manager_challenges
  end

  def show
    @challenge = current_user.challenge_manager_challenges.find(params[:challenge_id])
    @phase = @challenge.phases.find(params[:phase_id])
    @submission = @phase.submissions.find(params[:id])
  end

  def update
    @submission = Submission.find(params[:id])

    if @submission.update!(submission_params)
      flash.now[:success] = I18n.t("comments_saved")
      render :show, submission: @submission
    else
      render :show, status: :unprocessable_entity, submission: @submission
    end
  end

  def by_challenge_phase
    @challenge = current_user.challenge_manager_challenges.find(params[:challenge_id])
    @phase = @challenge.phases.find(params[:id])
    @submissions = @phase.submissions
  end

  def submission_params
    params.require(:submission).permit(:comments)
  end
end
