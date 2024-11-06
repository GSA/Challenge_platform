# frozen_string_literal: true

class ManageSubmissionsController < ApplicationController
  before_action -> { authorize_user('challenge_manager') }
  def index
    @challenges = current_user.challenge_manager_challenges
  end

  def by_challenge_phase
    @phase = Phase.where(id: params[:phase_id],
                         challenge_id: current_user.challenge_manager_challenges.collect(&:id)).first
    @submissions = if @phase then @phase.submissions else [] end
  end
end
 