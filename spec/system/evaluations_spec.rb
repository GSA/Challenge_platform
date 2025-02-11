require 'rails_helper'

RSpec.describe 'Evaluation', :js, type: :system do
  let(:evaluator) { create(:user, :evaluator) }
  let(:challenge) { create(:challenge) }
  let(:submission) { create(:submission, challenge: challenge, phase: challenge.phases[0]) }
  let!(:evaluation_form) do
    create(:evaluation_form, :pointed, challenge: challenge, phase: submission.phase, evaluation_criteria_attrs: [
             { title: "Criterion 1", points_or_weight: 50, scoring_type: :numeric },
             { title: "Criterion 2", points_or_weight: 25, scoring_type: :binary },
             { title: "Criterion 3", points_or_weight: 25, scoring_type: :rating }
           ])
  end
  let(:challenge_phases_evaluator) do
    create(:challenge_phases_evaluator, challenge:, phase: submission.phase, user: evaluator)
  end
  let!(:assignment) { create(:evaluator_submission_assignment, evaluator: evaluator, submission: submission) }

  before do
    system_login_user(evaluator)
  end

  it 'displays the evaluation form title and instructions' do
    visit new_submission_evaluation_path(submission)

    expect(page).to have_content(evaluation_form.title)
    expect(page).to have_content(evaluation_form.instructions)
  end

  it 'saves the form as a draft' do
    visit new_submission_evaluation_path(submission)

    click_button 'Save Draft'
    expect(page).to have_content('Evaluation saved as draft')
  end

  it 'validates presence of required fields' do
    visit new_submission_evaluation_path(submission)

    click_button 'Mark Complete'

    assert_selector 'dialog#complete', visible: true

    within 'dialog#complete' do
      click_link_or_button 'Yes'
    end

    expect(page).to have_content("prohibited this evaluation from being saved")
  end

  it 'allows entering scores for evaluation criteria' do
    pending "Fix filling in other criteria types and helper function. Check calced scores"

    # evaluation_form.evaluation_criteria.each do |criterion|
    #   within("[data-criterion][data-scoring-type='#{criterion.scoring_type}']") do
    #     if criterion.scoring_type == 'numeric'
    #       fill_in 'evaluation_score[score]', with: criterion.points_or_weight
    #     end
    #   end
    # end
    # TODO: Fix this when updating test
    total_score = 0
    expect(page).to have_content(total_score)
  end

  it 'submits the form and marks the evaluation as complete' do
    pending "Use criteria filling function to fill all criteria"
    # evaluation_form.evaluation_criteria.each do |criterion|
    #   within("[data-criterion][data-scoring-type='#{criterion.scoring_type}']") do
    #     if criterion.scoring_type == 'numeric'
    #       fill_in 'evaluation_score[score]', with: criterion.points_or_weight
    #     end
    #   end
    # end

    # click_button 'Mark Complete'
    # click_button 'Yes'
    expect(page).to have_content('Evaluation completed successfully')
  end
end
