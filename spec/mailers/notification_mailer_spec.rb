require 'rails_helper'

RSpec.describe NotificationMailer, type: :mailer do
  let(:challenge) { create(:challenge, title: "Test Challenge") }
  let(:phase) { create(:phase, challenge: challenge) }
  let(:challenge_manager) { create(:user, role: "challenge_manager") }
  let!(:challenge_manager_assignment) { create(:challenge_manager, user: challenge_manager, challenge: challenge) }

  shared_examples "includes challenge manager contact info" do
    it "includes challenge manager contact information" do
      expect(mail.body.encoded).to include(challenge_manager.email)
      expect(mail.body.encoded).to include(ERB::Util.html_escape(challenge_manager.first_name))
      expect(mail.body.encoded).to include(ERB::Util.html_escape(challenge_manager.last_name))
    end
  end

  describe "#evaluation_invitation" do
    let(:invitation) { create(:evaluator_invitation, phase: phase, challenge: challenge) }
    let(:mail) { described_class.evaluation_invitation(invitation) }

    it "renders the headers" do
      expect(mail.subject).to eq(I18n.t("mailers.evaluation_invitation.subject", challenge_title: challenge.title))
      expect(mail.to).to eq([invitation.email])
      expect(mail.from).to eq(["team@challenge.gov"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match(/You have been invited to #{challenge.title}/)
      expect(mail.body.encoded).to match(/create a Challenge.gov account via Login.gov/)
    end

    include_examples "includes challenge manager contact info"

    context "when resending invitation" do
      let(:invitation) { create(:evaluator_invitation, phase: phase, challenge: challenge) }

      it "sends the invitation email again" do
        expect {
          EvaluatorManagementService.new(challenge, phase).resend_invitation(invitation)
        }.to change { ActionMailer::Base.deliveries.count }.by(1)

        mail = ActionMailer::Base.deliveries.last
        expect(mail.subject).to eq(I18n.t("mailers.evaluation_invitation.subject", challenge_title: challenge.title))
        expect(mail.to).to eq([invitation.email])
      end
    end
  end

  describe "#role_request" do
    let(:user) { create(:user, role: "solver") }
    let(:mail) { described_class.role_request(user, challenge, phase) }

    it "renders the headers" do
      expect(mail.subject).to eq(I18n.t("mailers.evaluation_invitation.subject", challenge_title: challenge.title))
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(["team@challenge.gov"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match(/You have been invited to #{challenge.title}/)
      expect(mail.body.encoded).to match(/request your role to be changed to an evaluator/)
      expect(mail.body.encoded).to match(/currently have a Challenge.gov account as a #{user.role}/)
    end

    include_examples "includes challenge manager contact info"
  end

  describe "#evaluation_assignment" do
    let(:evaluator) { create(:user, role: "evaluator", status: "active") }
    let(:submission) { create(:submission, challenge: challenge, phase: phase) }
    let(:assignment) { create(:evaluator_submission_assignment, evaluator: evaluator, submission: submission, status: :assigned) }
    let(:mail) { described_class.evaluation_assignment(assignment) }

    it "renders the headers" do
      expect(mail.subject).to eq(I18n.t("mailers.evaluation_assignment.subject", submission_id: submission.id))
      expect(mail.to).to eq([evaluator.email])
      expect(mail.from).to eq(["team@challenge.gov"])
    end

    it "renders the body" do
      due_date = phase.end_date.strftime("%m/%d/%Y")
      expect(mail.body.encoded).to match(/You have been assigned to evaluate/)
      expect(mail.body.encoded).to match(/submission #{submission.id}/)
      expect(mail.body.encoded).to match(/Evaluations are due by #{due_date}/)
    end

    include_examples "includes challenge manager contact info"

    context "when reassigning an evaluator" do
      let(:unassigned_assignment) { create(:evaluator_submission_assignment, evaluator: evaluator, submission: submission, status: :unassigned) }

      it "sends assignment email when status changes to assigned" do
        expect {
          unassigned_assignment.update!(status: :assigned)
          NotificationMailer.evaluation_assignment(unassigned_assignment).deliver_now
        }.to change { ActionMailer::Base.deliveries.count }.by(1)

        mail = ActionMailer::Base.deliveries.last
        expect(mail.subject).to eq(I18n.t("mailers.evaluation_assignment.subject", submission_id: submission.id))
        expect(mail.to).to eq([evaluator.email])
        expect(mail.body.encoded).to match(/You have been assigned to evaluate/)
        expect(mail.body.encoded).to match(/submission #{submission.id}/)
      end
    end
  end

  describe "#recusal" do
    let(:evaluator) { create(:user, role: "evaluator", status: "active") }
    let(:submission) { create(:submission, challenge: challenge, phase: phase) }
    let(:assignment) { create(:evaluator_submission_assignment, evaluator: evaluator, submission: submission, status: :recused) }
    let(:mail) { described_class.recusal(assignment) }

    before do
      challenge.challenge_managers.destroy_all
      create(:challenge_manager, user: challenge_manager, challenge: challenge)
    end

    it "renders the headers" do
      expect(mail.subject).to eq(I18n.t("mailers.recusal.subject", submission_id: submission.id))
      expect(mail.to).to eq([challenge_manager.email])
      expect(mail.from).to eq(["team@challenge.gov"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match(/An evaluator recused from evaluating/)
      expect(mail.body.encoded).to match(/submission #{submission.id}/)
      expect(mail.body.encoded).to match(/#{evaluator.email}/)
    end

    context "with multiple challenge managers" do
      let(:second_manager) { create(:user, role: "challenge_manager") }

      before do
        create(:challenge_manager, user: second_manager, challenge: challenge)
      end

      it "sends to all challenge managers" do
        expect(mail.to).to match_array([challenge_manager.email, second_manager.email])
      end
    end

    include_examples "includes challenge manager contact info"
  end
end
