# frozen_string_literal: true

module ManageSubmissionsHelper
  def eligible_for_evaluation?(submission)
    submission.judging_status.in?(%w[qualified selected winner])
  end

  def selected_to_advance?(submission)
    submission.judging_status.in?(%w[selected winner])
  end

  def assigned_to_user?(user, submission)
    submission.challenge_id.in?(user.challenge_manager_challenges.collect(&:id))
  end 
end
