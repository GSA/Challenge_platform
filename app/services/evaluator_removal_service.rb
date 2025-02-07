# frozen_string_literal: true

# This service handles removing evalutors and evaluator invitations from a challenge phase.
class EvaluatorRemovalService
  def initialize(challenge, phase)
    @challenge = challenge
    @phase = phase
  end

  def remove_evaluator(evaluator_type, evaluator_id)
    case evaluator_type
    when 'user'
      remove_user_evaluator(evaluator_id)
    when 'invitation'
      remove_evaluator_invitation(evaluator_id)
    else
      { success: false, message: 'Invalid evaluator type' }
    end
  end

  private

  def remove_user_evaluator(evaluator_id)
    ActiveRecord::Base.transaction do
      evaluator = User.find(evaluator_id)
      cpe = ChallengePhasesEvaluator.find_by(challenge: @challenge, phase: @phase, user: evaluator)

      next evaluator_not_found_response unless cpe

      delete_evaluator_assignments(evaluator)
      delete_challenge_phase_evaluator(cpe)
    end
  rescue ActiveRecord::RecordNotFound
    evaluator_not_found_response
  rescue StandardError => e
    { success: false, message: "Error: #{e.message}" }
  end

  def remove_evaluator_invitation(invitation_id)
    invitation = @challenge.evaluator_invitations.find_by!(id: invitation_id, phase: @phase)
    if invitation.destroy
      { success: true, message: I18n.t('evaluators.remove_evaluator_invitation.success') }
    else
      { success: false, message: I18n.t('evaluators.remove_evaluator_invitation.failure') }
    end
  rescue ActiveRecord::RecordNotFound
    { success: false, message: I18n.t('evaluators.remove_evaluator_invitation.invitation_not_found') }
  rescue StandardError => e
    { success: false, message: "Error: #{e.message}" }
  end

  # deletes each evaluator submission assignment and its associated evaluation
  def delete_evaluator_assignments(evaluator)
    EvaluatorSubmissionAssignment.where(
      user_id: evaluator.id,
      submission_id: @phase.submissions.select(:id)
    ).destroy_all
  end

  def delete_challenge_phase_evaluator(cpe)
    if cpe.destroy
      { success: true, message: I18n.t('evaluators.remove_user_evaluator.success') }
    else
      { success: false, message: I18n.t('evaluators.remove_user_evaluator.failure') }
    end
  end

  def evaluator_not_found_response
    { success: false, message: I18n.t('evaluators.remove_user_evaluator.evaluator_not_found') }
  end
end
