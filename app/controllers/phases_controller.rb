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

    @not_started = @submissions.left_outer_joins(:evaluations)
      .where(evaluations: { id: nil })

    @in_progress = @submissions.joins(:evaluations)
      .where(evaluations: { completed_at: nil })

    @completed = @submissions.joins(:evaluations)
      .where.not(evaluations: { completed_at: nil })

    @submissions_by_status = {
      not_started: @not_started.count,
      in_progress: @in_progress.count,
      completed: @completed.count
    }

    apply_filters
    apply_sorting
  end

  private

  def set_phase
    @phase = Phase.where(challenge: current_user.challenge_manager_challenges).find(params[:id])
    @challenge = @phase.challenge
  end

  private

  def apply_filters
    case params[:status]
    when 'not_started'
      @submissions = @not_started
    when 'in_progress'
      @submissions = @in_progress
    when 'completed'
      @submissions = @completed
    when 'recused'
      @submissions = @submissions.joins(:evaluator_submission_assignments).
        where(evaluator_submission_assignments: { status: :recused })
    end

    @submissions = @submissions.select(&:eligible_for_evaluation?) if params[:eligible_for_evaluation] == 'true'
    @submissions = @submissions.select(&:selected_to_advance?) if params[:selected_to_advance] == 'true'
  end

  def apply_sorting
    case params[:sort]
    when 'average_score_high_to_low'
      @submissions = @submissions.order_by_average_score(:desc)
    when 'average_score_low_to_high'
      @submissions = @submissions.order_by_average_score(:asc)
    when 'submission_id_high_to_low'
      @submissions = @submissions.order(id: :desc)
    when 'submission_id_low_to_high'
      @submissions = @submissions.order(id: :asc)
    end
  end
end
