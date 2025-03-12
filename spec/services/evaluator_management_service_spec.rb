require 'rails_helper'

RSpec.describe EvaluatorManagementService do
  let(:user) { create_and_log_in_user(role: 'challenge_manager') }
  let(:challenge) { create(:challenge) }
  let(:phase) { create(:phase, challenge: challenge) }
  let(:service) { described_class.new(challenge, phase) }

  describe '#process_evaluator_invitation' do
    context 'with an existing user' do
      let(:evaluator) { create(:user, role: 'evaluator') }

      it 'adds the user as an evaluator if not already added' do
        result = service.process_evaluator_invitation(
          evaluator.email,
          {
            email: evaluator.email,
            full_name: 'Santos Bickford'
          }
        )
        expect(result[:success]).to be true
        expect(result[:message]).to include('has been added as an evaluator')
        expect(ChallengePhasesEvaluator.where(challenge: challenge, phase: phase, user: evaluator).count).to eq(1)
      end

      it 'does not add the user if already an evaluator' do
        create(:challenge_phases_evaluator, challenge: challenge, phase: phase, user: evaluator)
        result = service.process_evaluator_invitation(evaluator.email, { email: evaluator.email, full_name: 'Santos Bickford' })
        expect(result[:success]).to be true
        expect(result[:message]).to include('has already been added as an evaluator')
        expect(ChallengePhasesEvaluator.where(challenge: challenge, phase: phase, user: evaluator).count).to eq(1)
      end

      it 'does not add the user with an invalid role' do
        evaluator.update(role: 'admin')
        result = service.process_evaluator_invitation(evaluator.email, { email: evaluator.email, full_name: 'Lois Lane' })
        expect(result[:success]).to be false
        expect(result[:message]).to include('does not have a valid evaluator role')
      end

      it 'requires full name when adding an existing user' do
        result = service.process_evaluator_invitation(evaluator.email, { email: evaluator.email, full_name: 'Santos' })
        expect(result[:success]).to be false
        expect(result[:message]).to eq("Please provide evaluator's full name")
      end

      it 'updates user name when adding as evaluator' do
        result = service.process_evaluator_invitation(
          evaluator.email,
          {
            email: evaluator.email,
            full_name: 'Santos Bickford'
          }
        )
        expect(result[:success]).to be true
        evaluator.reload
        expect(evaluator.first_name).to eq('Santos')
        expect(evaluator.last_name).to eq('Bickford')
      end
    end

    context 'with a new user' do
      let(:email) { 'new_evaluator@example.com' }
      let(:invitation_params) do
        {
          email: email,
          first_name: 'John',
          last_name: 'Doe',
          last_invite_sent: Time.current
        }
      end

      it 'creates a new invitation and sends notification email' do
        expect do
          result = service.process_evaluator_invitation(email, invitation_params)
          expect(result[:success]).to be true
          expect(result[:message]).to include('Invitation sent')
          expect(EvaluatorInvitation.find_by(email: email)).to be_present
        end.to change { EvaluatorInvitation.count }.by(1)
           .and change { ActionMailer::Base.deliveries.count }.by(1)

        mail = ActionMailer::Base.deliveries.last
        expect(mail.subject).to eq(I18n.t("mailers.evaluation_invitation.subject",
                                         challenge_title: challenge.title))
        expect(mail.to).to eq([email])
      end

      it 'resends an existing invitation with notification email' do
        create(:evaluator_invitation, challenge: challenge, phase: phase, email: email)
        result = service.process_evaluator_invitation(email, { email: email })
        expect(result[:success]).to be true
        expect(result[:message]).to include('Invitation has been resent')
        expect(EvaluatorInvitation.count).to eq(1)

        expect(ActionMailer::Base.deliveries.count).to eq(1)
        mail = ActionMailer::Base.deliveries.last
        expect(mail.subject).to eq(I18n.t("mailers.evaluation_invitation.subject",
                                         challenge_title: challenge.title))
        expect(mail.to).to eq([email])
      end
    end

    context 'with an existing user needing role change' do
      let(:solver) { create(:user, role: 'solver', status: 'active') }

      it 'sets status to evaluator_role_requested when user is not an evaluator role' do
        result = service.process_evaluator_invitation(
          solver.email,
          { email: solver.email, full_name: 'Mickey Lee' }
        )

        expect(result[:success]).to be true
        expect(result[:message]).to include('requires a role change to evaluator')
        expect(solver.reload.status).to eq('evaluator_role_requested')

        expect(ActionMailer::Base.deliveries.count).to eq(1)
        mail = ActionMailer::Base.deliveries.last
        expect(mail.subject).to eq(I18n.t("mailers.evaluation_invitation.subject",
                                         challenge_title: challenge.title))
      end

      it 'does not set evaluator_role_requested for users with evaluator role' do
        evaluator = create(:user, role: 'evaluator', status: 'active')
        result = service.process_evaluator_invitation(
          evaluator.email,
          { email: solver.email, full_name: 'Daisy Donald' }
        )

        expect(result[:success]).to be true
        expect(evaluator.reload.status).to eq('active')
      end
    end
  end

  describe '#remove_evaluator' do
    context 'when removing a user evaluator' do
      let(:evaluator) { create(:user, role: 'evaluator') }
      let!(:cpe) { create(:challenge_phases_evaluator, challenge: challenge, phase: phase, user: evaluator) }
      let!(:submission1) { create(:submission, challenge: challenge, phase: phase) }
      let!(:submission2) { create(:submission, challenge: challenge, phase: phase) }
      let!(:submission_other_phase) { create(:submission, challenge: challenge, phase: create(:phase, challenge: challenge)) }

      context 'with multiple assignments and evaluations' do
        let!(:assignment1) do
          create(:evaluator_submission_assignment,
                submission: submission1,
                evaluator: evaluator,
                status: :assigned)
        end

        let!(:assignment2) do
          create(:evaluator_submission_assignment,
                submission: submission2,
                evaluator: evaluator,
                status: :recused)
        end

        let!(:assignment_other_phase) do
          create(:evaluator_submission_assignment,
                submission: submission_other_phase,
                evaluator: evaluator,
                status: :assigned)
        end

        let!(:evaluation1) do
          create(:evaluation,
                evaluator_submission_assignment: assignment1,
                submission: submission1,
                user: evaluator)
        end

        let!(:evaluation2) do
          create(:evaluation,
                evaluator_submission_assignment: assignment2,
                submission: submission2,
                user: evaluator)
        end

        it 'removes only assignments and evaluations for the specified phase' do
          expect {
            result = service.remove_evaluator('user', evaluator.id)
            expect(result[:success]).to be true
          }.to change { ChallengePhasesEvaluator.count }.by(-1)
            .and change { EvaluatorSubmissionAssignment.count }.by(-2)
            .and change { Evaluation.count }.by(-2)

          expect(ChallengePhasesEvaluator.find_by(id: cpe.id)).to be_nil
          expect(EvaluatorSubmissionAssignment.find_by(id: assignment1.id)).to be_nil
          expect(EvaluatorSubmissionAssignment.find_by(id: assignment2.id)).to be_nil
          expect(Evaluation.find_by(id: evaluation1.id)).to be_nil
          expect(Evaluation.find_by(id: evaluation2.id)).to be_nil

          expect(EvaluatorSubmissionAssignment.find_by(id: assignment_other_phase.id)).to be_present
        end
      end

      context 'with assignments but no evaluations' do
        let!(:assignment_no_eval) do
          create(:evaluator_submission_assignment,
                submission: submission1,
                evaluator: evaluator,
                status: :assigned)
        end

        it 'removes assignments without evaluations' do
          expect {
            result = service.remove_evaluator('user', evaluator.id)
            expect(result[:success]).to be true
          }.to change { ChallengePhasesEvaluator.count }.by(-1)
            .and change { EvaluatorSubmissionAssignment.count }.by(-1)
            .and change { Evaluation.count }.by(0)

          expect(ChallengePhasesEvaluator.find_by(id: cpe.id)).to be_nil
          expect(EvaluatorSubmissionAssignment.find_by(id: assignment_no_eval.id)).to be_nil
        end
      end

      context 'when evaluator has no assignments' do
        it 'only removes the challenge phase evaluator record' do
          expect {
            result = service.remove_evaluator('user', evaluator.id)
            expect(result[:success]).to be true
          }.to change { ChallengePhasesEvaluator.count }.by(-1)
            .and change { EvaluatorSubmissionAssignment.count }.by(0)
            .and change { Evaluation.count }.by(0)

          expect(ChallengePhasesEvaluator.find_by(id: cpe.id)).to be_nil
        end
      end

      context 'with successful removal' do
        it 'returns success message' do
          result = service.remove_evaluator('user', evaluator.id)
          expect(result[:success]).to be true
          expect(result[:message]).to eq(I18n.t('evaluators.remove_user_evaluator.success'))
        end
      end

      context 'when evaluator is not found' do
        it 'returns not found message' do
          result = service.remove_evaluator('user', -1)
          expect(result[:success]).to be false
          expect(result[:message]).to eq(I18n.t('evaluators.remove_user_evaluator.evaluator_not_found'))
        end
      end

      context 'when cpe deletion fails' do
        before do
          allow_any_instance_of(ChallengePhasesEvaluator).to receive(:destroy).and_return(false)
        end

        it 'returns failure message' do
          result = service.remove_evaluator('user', evaluator.id)
          expect(result[:success]).to be false
          expect(result[:message]).to eq(I18n.t('evaluators.remove_user_evaluator.failure'))
        end
      end
    end

    context 'when removing an invitation' do
      let!(:invitation) { create(:evaluator_invitation, challenge: challenge, phase: phase) }

      it 'removes the invitation successfully' do
        result = service.remove_evaluator('invitation', invitation.id)
        expect(result[:success]).to be true
        expect(result[:message]).to include('Evaluator invitation successfully removed')
        expect(EvaluatorInvitation.find_by(id: invitation.id)).to be_nil
      end

      context 'with successful removal' do
        it 'returns success message' do
          result = service.remove_evaluator('invitation', invitation.id)
          expect(result[:success]).to be true
          expect(result[:message]).to eq(I18n.t('evaluators.remove_evaluator_invitation.success'))
        end
      end

      context 'when invitation is not found' do
        it 'returns not found message' do
          result = service.remove_evaluator('invitation', -1)
          expect(result[:success]).to be false
          expect(result[:message]).to eq(I18n.t('evaluators.remove_evaluator_invitation.invitation_not_found'))
        end
      end

      context 'when invitation deletion fails' do
        before do
          allow_any_instance_of(EvaluatorInvitation).to receive(:destroy).and_return(false)
        end

        it 'returns failure message' do
          result = service.remove_evaluator('invitation', invitation.id)
          expect(result[:success]).to be false
          expect(result[:message]).to eq(I18n.t('evaluators.remove_evaluator_invitation.failure'))
        end
      end
    end

    it 'handles invalid evaluator types' do
      result = service.remove_evaluator('invalid', 1)
      expect(result[:success]).to be false
      expect(result[:message]).to eq('Invalid evaluator type')
    end
  end

  describe '.accept_evaluator_invitation' do
    let(:evaluator) { create(:user, role: 'evaluator') }
    let!(:invitation) { create(:evaluator_invitation, challenge: challenge, phase: phase, email: evaluator.email) }

    it 'processes all invitations for the user' do
      expect do
        described_class.accept_evaluator_invitation(evaluator)
      end.to change { ChallengePhasesEvaluator.count }.by(1).
        and change { EvaluatorInvitation.count }.by(-1)
    end

    it 'returns a success message' do
      result = described_class.accept_evaluator_invitation(evaluator)
      expect(result).to eq({ success: true, message: 'Evaluator created and added to challenge phase successfully.' })
    end
  end

  describe '.resend_invitation' do
    let(:evaluator) { create(:user, role: 'evaluator') }
    let(:invitation) { create(:evaluator_invitation, challenge: challenge, phase: phase, email: evaluator.email) }

    it 'updates the invitation last_invite_sent' do
      expect { service.resend_invitation(invitation) }.to change { invitation.reload.last_invite_sent }
    end
  end
end
