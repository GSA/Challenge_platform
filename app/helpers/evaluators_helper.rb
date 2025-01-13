# frozen_string_literal: true

# View helpers for rendering users with the evaluator role.
module EvaluatorsHelper
  def user_status(evaluator)
    return "Invite Sent" unless evaluator.is_a?(User)

    evaluator.status == 'active' ? "Available" : "Awaiting Approval"
  end
end
