# frozen_string_literal: true

# Controller for evaluations CRUD actions.
class EvaluationsController < ApplicationController
  before_action -> { authorize_user('evaluator') }
  before_action :set_phase, except: [:index]

  def index
    @challenges = Challenge.joins(phases: :challenge_phases_evaluators).
      where(challenge_phases_evaluators: { user_id: current_user.id }).
      includes(phases: [:evaluation_form]).
      distinct
  end

  def submissions
    @assigned_submissions = @phase.evaluator_submission_assignments.
      where(evaluator: current_user).
      where(status: %i[assigned recused]).
      includes(:submission, :evaluation).
      ordered_by_status

    @submissions_count = helpers.calculate_submissions_count(@assigned_submissions)
  end

  private

  def set_phase
    @phase = Phase.joins(:challenge_phases_evaluators).
      where(challenge_phases_evaluators: { user_id: current_user.id }).
      find(params[:id])
    @challenge = @phase.challenge
  end
end
