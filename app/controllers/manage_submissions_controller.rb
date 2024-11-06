# frozen_string_literal: true

class ManageSubmissionsController < ApplicationController
  before_action -> { authorize_user('challenge_manager') }
  def index
    @challenges = current_user.challenge_manager_challenges
  end

  def show
    @challenge = current_user.challenge_manager_challenges.find(params[:challenge_id])
    @phase = @challenge.phases.find(params[:id])
    @submissions = @phase.submissions
  end
end
