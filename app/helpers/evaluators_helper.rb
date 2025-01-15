# frozen_string_literal: true

# View helpers for rendering users with the evaluator role.
module EvaluatorsHelper
  def user_status(evaluator)
    return "Invite Sent" unless evaluator.is_a?(User)

    case evaluator.status
    when 'active'
      "Available"
    when 'evaluator_role_requested'
      "Role Change Needed"
    else
      "Awaiting Approval" # pending
    end
  end
end
