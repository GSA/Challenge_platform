# frozen_string_literal: true

# Controller for challenge phases CRUD actions.
class PhasesController < ApplicationController
  before_action -> { authorize_user('challenge_manager') }
  before_action :set_phase, except: [:index]

  def index
    @challenges = current_user.challenge_manager_challenges.includes([phases: [:evaluation_form]])
  end

  def submissions
    @submissions = @phase.submissions
    @submissions_count = @submissions.count
    not_started = @submissions.left_outer_joins(:evaluations).
      where({ "evaluations.id" => nil }).count
    in_progress = @submissions.joins(:evaluations).
      select("submissions.id").where({ "evaluations.completed_at" => nil }).distinct.count
    completed = @submissions_count - in_progress - not_started
    @submissions_by_status = { not_started:, in_progress:, completed: }
  end

  private

  def set_phase
    @phase = Phase.where(challenge: current_user.challenge_manager_challenges).find(params[:id])
    @challenge = @phase.challenge
  end
end
