# frozen_string_literal: true

class ManageSubmissionsController < ApplicationController
  before_action -> { authorize_user('challenge_manager') }
  def index
    @challenges = current_user.challenge_manager_challenges
  end

  def show
    @submission = Submission.find(params[:id])
    @assigned = @submission.challenge_id.in?(current_user.challenge_manager_challenges.collect(&:id))
  end  

  def by_challenge_phase
    @phase = Phase.where(id: params[:phase_id],
                         challenge_id: current_user.challenge_manager_challenges.collect(&:id)).first
    @submissions = @phase ? @phase.submissions : []
  end
end
