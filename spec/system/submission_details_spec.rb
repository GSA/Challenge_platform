# frozen_string_literal: true

require 'rails_helper'

describe "A11y", :js do
  describe "Logged-in as a Challenge Manager" do
    let(:user) { create_user(role: "challenge_manager") }
    let(:challenge) { create_challenge(user: user, title: "Boston Tea Party Cleanup") }
    let(:phase) { create(:phase, challenge: challenge) }
    let(:submission) { create(:submission, challenge:, phase:, manager: user, status: "submitted") }
    let(:fake_comments) { Faker::Lorem.sentence }

    before do
      create(:challenge_manager, challenge:, user:)
      system_login_user(user)
    end

    it "submission details page is accessible" do
      visit submission_path(submission)
      expect(user.role).to eq("challenge_manager")
      expect(page).to have_css('h1', text: "Submission ID #{submission.id}")
      expect(page).to(be_axe_clean)
    end

    it "allows marking judging status eligible for evaluation" do
      visit submission_path(submission)

      eligible_input = page.find_by_id('eligible-for-evaluation').find('input.usa-checkbox__input', visible: :hidden)
      expect(eligible_input).not_to be_checked
      find_by_id('eligible-for-evaluation').click
      click_on "Save"
      expect(page).to have_css("p.usa-alert__text", text: "Submission was updated successfully.")
      eligible_input = page.find_by_id('eligible-for-evaluation').find('input.usa-checkbox__input', visible: :hidden)
      expect(eligible_input).to be_checked
      expect(submission.reload.judging_status).to eq("selected")
    end

    it "allows marking judging status selected to advance" do
      # evaluations must exist and all be completed before selecting the submission to advance
      evaluator = create_user(role: "evaluator")
      submission.update(judging_status: :selected)
      assignment = create(:evaluator_submission_assignment, status: :assigned, evaluator:, submission:)
      create(:evaluation, evaluator_submission_assignment: assignment, completed_at: Time.current)

      visit submission_path(submission)
      selected_input = page.find_by_id('selected-to-advance').find('input.usa-checkbox__input', visible: :hidden)
      expect(selected_input).not_to be_checked
      find_by_id('selected-to-advance').click
      click_on "Save"
      expect(page).to have_css("p.usa-alert__text", text: "Submission was updated successfully.")
      selected_input = page.find_by_id('selected-to-advance').find('input.usa-checkbox__input', visible: :hidden)
      expect(selected_input).to be_checked
      expect(submission.reload.judging_status).to eq("winner")
    end

    it "saves comments" do
      visit submission_path(submission)
      fill_in "Comments and notes:", with: fake_comments
      click_on "Save"
      expect(page).to have_css("p.usa-alert__text", text: "Submission was updated successfully.")
      assert_text(fake_comments)
    end

    it "displays a list of available evaluators" do
      evaluator1 = create_user(role: "evaluator")
      evaluator2 = create_user(role: "evaluator")
      challenge.challenge_phases_evaluators.create(user: evaluator1, phase: phase)
      challenge.challenge_phases_evaluators.create(user: evaluator2, phase: phase)
      evaluation_form = create(:evaluation_form, phase: phase, challenge: challenge)
      visit submission_path(submission)
      find_by_id('eligible-for-evaluation').click
      click_on('Save')

      expect(page).to have_content("Available Evaluators")
      expect(page).to have_content(evaluator1.email)
      expect(page).to have_content(evaluator2.email)
    end

    it "assigns and unassigns an evaluator to the submission" do
      evaluator = create_user(role: "evaluator")
      challenge.challenge_phases_evaluators.create(user: evaluator, phase: phase)
      evaluation_form = create(:evaluation_form, phase: phase, challenge: challenge)
      visit submission_path(submission)
      find_by_id('eligible-for-evaluation').click
      click_on('Save')

      expect(page).to have_content("You currently do not have any evaluators assigned to this submission.")

      click_on('Assign')
      expect(page).to have_css("p.usa-alert__text", text: "Evaluator assigned successfully")

      click_on('Unassign')
      expect(page).to have_css("p.usa-alert__text", text: "Evaluator unassigned successfully")
    end

    it "unassigns a recused evaluator from the submission" do
      evaluator = create_user(role: "evaluator")
      challenge.challenge_phases_evaluators.create(user: evaluator, phase: phase)
      evaluation_form = create(:evaluation_form, phase: phase, challenge: challenge)
      visit submission_path(submission)
      find_by_id('eligible-for-evaluation').click
      click_on('Save')

      click_on('Assign')
      expect(page).to have_css("p.usa-alert__text", text: "Evaluator assigned successfully")

      EvaluatorSubmissionAssignment.where(user_id: evaluator.id, submission_id: submission.id).update!(status: "recused")

      visit submission_path(submission)
      click_on('Unassign')
      expect(page).to have_css("p.usa-alert__text", text: "Recused evaluator unassigned successfully")
    end
  end
end