require 'rails_helper'

RSpec.describe 'Evaluator Submission Assignments', :js, type: :system do
  let(:user) { create_user(role: "challenge_manager", status: "active") }
  let(:challenge) { create(:challenge) }
  let(:phase) { create(:phase, challenge: challenge) }
  let(:evaluator) { create(:user, role: 'evaluator') }
  let(:submission) { create(:submission, phase: phase, challenge: challenge) }
  let!(:evaluation_form) do
    create(:evaluation_form, phase: phase, challenge: challenge, closing_date: 1.month.from_now)
  end

  before do
    ChallengeManager.create!(user: user, challenge: challenge)
    ChallengePhasesEvaluator.create!(challenge: challenge, phase: phase, user: evaluator)
    system_login_user(user)
  end

  it 'is accessible' do
    visit phase_evaluator_submission_assignments_path(phase, evaluator_id: evaluator.id)
    expect(page).to have_content(evaluator.first_name)
    expect(page).to be_axe_clean
  end

  it 'allows unassigning a submission from an evaluator', :js do
    assigned_assignment = create(
      :evaluator_submission_assignment,
      submission: submission,
      evaluator: evaluator,
      status: :assigned
    )

    visit phase_evaluator_submission_assignments_path(phase, evaluator_id: evaluator.id)

    unassign_button = find("button[data-assignment-id='#{assigned_assignment.id}']", text: 'Unassign')
    expect(unassign_button).to be_visible
    unassign_button.click

    expect(page).to have_css('#unassign-evaluator-submission-modal', visible: true)
    expect(page).to have_content('Are you sure you want to unassign an evaluator from this submission?')

    within('#unassign-evaluator-submission-modal') do
      click_button 'Yes'
    end
  end

  it 'allows assigning a submission to an evaluator', bullet: :dont_raise do
    unassigned_assignment = create(
      :evaluator_submission_assignment,
      submission: submission,
      evaluator: evaluator,
      status: :unassigned
    )

    expect(unassigned_assignment.reload.status).to eq('unassigned')
    visit phase_evaluator_submission_assignments_path(phase, evaluator_id: evaluator.id)

    click_button "Reassign"

    expect(page).to have_content(I18n.t('evaluator_submission_assignments.assigned.success'))
    expect(unassigned_assignment.reload.status).to eq('assigned')
  end
end
