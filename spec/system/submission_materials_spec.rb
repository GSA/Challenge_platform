require 'rails_helper'

RSpec.describe "Submission Materials", :js, type: :system do
  context "as a challenge manager" do
    let(:user) { create(:user, :challenge_manager) }
    let(:challenge) { create(:challenge, user:) }
    let(:submission) { create(:submission, challenge: challenge, phase: challenge.phases[0]) }

    before do
      create(:challenge_manager, challenge:, user:)
      system_login_user(user)
    end

    context "with a gov email" do
      before do
        user.update(email: generate_user_email(type: :gov))
      end

      it "allows me to view the submission materials page" do
        visit materials_submission_path(submission)

        assert_current_path materials_submission_path(submission)
        expect(page).to have_css('h2', text: "Submission ID #{submission.id}")
        expect(page).to(be_axe_clean)
      end
    end

    context "with a non gov email" do
      before do
        user.update(email: generate_user_email(type: :non_gov))
      end

      it "redirects me to the phases page" do
        visit materials_submission_path(submission)

        assert_current_path phases_path
        expect(page).to have_css('.usa-alert', text: I18n.t("access_denied"))
        expect(page).to(be_axe_clean)
      end
    end
  end

  context "as an evaluator" do
    let(:user) { create(:user, :evaluator) }
    let(:challenge) { create(:challenge) }
    let(:phase) { create(:phase, challenge: challenge) }
    let(:submission) { create(:submission, phase: phase, challenge: challenge) }
    let(:assignment) { create(:evaluator_submission_assignment, :assigned, submission:, evaluator: user) }

    before do
      system_login_user(user)
    end

    context "with a gov email" do
      before do
        user.update(email: generate_user_email(type: :gov))
      end

      it "allows me to view the submission materials page" do
        submission = assignment.submission

        visit materials_submission_path(submission)

        assert_current_path materials_submission_path(submission)
        expect(page).to have_css('h2', text: "Submission ID #{submission.id}")
        expect(page).to(be_axe_clean)
      end
    end

    context "with a non gov email" do
      before do
        user.update(email: generate_user_email(type: :non_gov))
      end

      it "redirects me to the evaluations page" do
        submission = assignment.submission

        visit materials_submission_path(submission)

        assert_current_path evaluations_path
        expect(page).to have_css('.usa-alert', text: I18n.t("access_denied"))
        expect(page).to(be_axe_clean)
      end
    end
  end
end
