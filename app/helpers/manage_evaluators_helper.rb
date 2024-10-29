module ManageEvaluatorsHelper

  def user_status(evaluator, challenge)
    if evaluator.is_a?(User)
      if challenge.challenge_phases_evaluators.exists?(user_id: evaluator.id)
        evaluator.status == 'active' ? "Available" : "Awaiting Approval"
      else
        "Invite Sent"
      end
    else # Evaluator invitation
      existing_user = User.find_by(email: evaluator.email)
      if existing_user
        existing_user.status == 'active' ? "Available" : "Awaiting Approval"
      else
        "Invite Sent"
      end
    end
  end

  def assigned_submissions_count(evaluator, challenge, phase)
    if evaluator.is_a?(User)
      evaluator.evaluator_submission_assignments
               .joins(:submission)
               .where(submissions: { challenge: challenge, phase: phase })
               .count
    else
      0
    end
  end
end
