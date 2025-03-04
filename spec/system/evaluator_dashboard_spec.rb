require 'rails_helper'

RSpec.describe 'Evaluator Dashboard', :js, type: :system do
  let(:evaluator) { create(:user, :evaluator) }
  let(:challenge) { create(:challenge) }
  let(:phase) { create(:phase, challenge:) }
  let(:submission) { create(:submission, challenge:, phase:) }
  let!(:evaluation_form) do
    create(:evaluation_form, :pointed, challenge:, phase:, evaluation_criteria_attrs: [
             { title: "Criterion 1", points_or_weight: 50, scoring_type: :numeric },
             { title: "Criterion 2", points_or_weight: 25, scoring_type: :binary },
             { title: "Criterion 3", points_or_weight: 25, scoring_type: :rating }
           ])
  end
  let(:challenge_phases_evaluator) do
    create(:challenge_phases_evaluator, challenge:, phase:, user: evaluator)
  end
  let!(:assignment) { create(:evaluator_submission_assignment, evaluator:, submission:) }

  before do
    system_login_user(evaluator)
  end

  it 'is accessible' do
    visit evaluations_path

    expect(page).to be_axe_clean
  end

  it 'contains the correct content' do
    visit evaluations_path

    expect(page).to have_content(challenge_phase_title(challenge, phase))
    expect(page).to have_content("1 of 1 Submissions")
    expect(page).to have_content(evaluation_form.closing_date.strftime("%m/%d/%Y"))
    expect(page).to have_content(evaluator_evaluation_status(evaluator, phase).to_s.titleize.upcase)
  end
end
