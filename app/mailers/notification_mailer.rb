class NotificationMailer < ApplicationMailer
  include PhasesHelper
  include EvaluationFormsHelper

  def evaluation_invitation(invitation)
    setup_challenge_attrs(invitation.phase.challenge, invitation.phase)
    @user = invitation

    mail(
      to: invitation.email,
      subject: I18n.t('mailers.evaluation_invitation.subject', challenge_title: invitation.phase.challenge.title)
    )
  end

  def role_request(user, challenge, phase)
    setup_challenge_attrs(challenge, phase)
    @user = user

    mail(
      to: user.email,
      subject: I18n.t('mailers.evaluation_invitation.subject', challenge_title: challenge.title)
    )
  end

  def evaluation_assignment(evaluator_submission_assignment)
    setup_assignment_attrs(evaluator_submission_assignment)
    @due_date = @submission.phase.end_date.strftime("%m/%d/%Y")

    mail(
      to: @evaluator.email,
      subject: I18n.t('mailers.evaluation_assignment.subject', submission_id: @submission.id)
    )
  end

  def recusal(evaluator_submission_assignment)
    setup_assignment_attrs(evaluator_submission_assignment)

    mail(
      to: @challenge_managers.map(&:email),
      subject: I18n.t('mailers.recusal.subject', submission_id: @submission.id)
    )
  end

  private

  def setup_challenge_attrs(challenge, phase)
    @challenge_phase_title = challenge_phase_title(challenge, phase)
    @challenge_managers = challenge.challenge_managers.includes(:user).map(&:user)
    attach_logo
  end

  def setup_assignment_attrs(assignment)
    @evaluator = assignment.evaluator
    @submission = assignment.submission
    setup_challenge_attrs(@submission.challenge, @submission.phase)
    @assignment = assignment
  end

  def attach_logo
    attachments.inline['challenge_gov_logo.png'] = File.read(Rails.root.join('public/platform-assets/images/challenge_gov_logo.png'))
  end
end
