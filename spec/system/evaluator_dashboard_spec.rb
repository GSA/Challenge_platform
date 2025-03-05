require 'rails_helper'

RSpec.describe 'Evaluator Dashboard', :js, type: :system do
  let(:evaluator) { create(:user, :evaluator) }
  let(:challenge) { create(:challenge) }
  let(:phase) { create(:phase, challenge:) }
  let(:submission) { create(:submission, challenge:, phase:) }
  let(:evaluation_form) do
    create(:evaluation_form, :pointed, challenge:, phase:, evaluation_criteria_attrs: [
             { title: "Criterion 1", points_or_weight: 50, scoring_type: :numeric },
             { title: "Criterion 2", points_or_weight: 25, scoring_type: :binary },
             { title: "Criterion 3", points_or_weight: 25, scoring_type: :rating }
           ])
  end

  context "without any assigned evaluations" do
    before do
      system_login_user(evaluator)
    end

    it 'is accessible' do
      visit evaluations_path

      expect(page).to have_css('h1', text: "My Evaluations")
      expect(page).to have_css('p', text: "You currently do not have any challenges.")
      expect(page).to be_axe_clean
    end
  end

  context "with an assigned evaluation" do
    let(:esa) { create(:evaluator_submission_assignment, :assigned, evaluator:, submission:) }
    let(:cpe) { create(:challenge_phases_evaluator, challenge:, phase:, user: evaluator) }

    before do
      evaluation_form
      cpe
      esa
      system_login_user(evaluator)
    end

    it 'is accessible' do
      visit evaluations_path

      expect(page).to be_axe_clean
    end

    it 'contains the correct content' do
      phase_title = challenge_phase_title(challenge, phase)
      visit evaluations_path

      expect(page).to have_css('h1', text: "My Evaluations")
      expect(page).to have_css('th[data-label="Challenge Title"]', text: phase_title)
      expect(page).to have_css('td[data-label="# of Submissions to Evaluate"]', text: "1 of 1 Submissions")
      expect(page).to have_css('td[data-label="Evaluation Due Date"]', text: evaluation_form.closing_date.strftime("%m/%d/%Y"))
      expect(page).to have_css('td[data-label="Evaluation Status"]', text: evaluator_evaluation_status(evaluator, phase).to_s.titleize.upcase)
    end

    it 'contains the correct content after being recused' do
      phase_title = challenge_phase_title(challenge, phase)
      esa.update(status: :recused)
      visit evaluations_path

      expect(page).to have_css('h1', text: "My Evaluations")
      expect(page).to have_css('th[data-label="Challenge Title"]', text: phase_title)
      expect(page).to have_css('td[data-label="# of Submissions to Evaluate"]', text: "1 of 1 Submissions")
      expect(page).to have_css('td[data-label="Evaluation Due Date"]', text: evaluation_form.closing_date.strftime("%m/%d/%Y"))
      expect(page).to have_css('td[data-label="Evaluation Status"]', text: evaluator_evaluation_status(evaluator, phase).to_s.titleize.upcase)
    end

    it 'contains the correct content after being unassigned' do
      esa.update(status: :unassigned)
      visit evaluations_path

      expect(page).to have_css('h1', text: "My Evaluations")
      expect(page).to have_css('p', text: "You currently do not have any challenges.")
    end
  end
end
