# frozen_string_literal: true

class ManageSubmissionsController < ApplicationController
  before_action -> { authorize_user('challenge_manager') }
  def index
    @challenges = current_user.challenge_manager_challenges
  end

  def by_challenge_phase
    @phase = current_user.challenge_manager_challenges.phases.find(params[:phase_id])
    @submissions = @phase.submissions
  end   
end
