require 'rails_helper'

RSpec.describe 'Evaluation', :js, type: :system do
  context "as an evaluator" do
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
    let!(:challenge_phases_evaluator) do
      create(:challenge_phases_evaluator, challenge:, phase: submission.phase, user: evaluator)
    end
    let!(:assignment) { create(:evaluator_submission_assignment, evaluator: evaluator, submission: submission) }

    before do
      system_login_user(evaluator)
    end

    context "with a gov email" do
      before do
        evaluator.update(email: generate_user_email(type: :gov))
      end

      it 'displays the evaluation form instructions' do
        visit new_submission_evaluation_path(submission)

        expect(page).to have_content(evaluation_form.instructions)
      end

      it 'saves the form as a draft', bullet: :dont_raise do
        visit new_submission_evaluation_path(submission)

        save_evaluation_draft

        expect(page).to have_content('Evaluation Draft is Saved')
      end

      it 'validates presence of required fields' do
        visit new_submission_evaluation_path(submission)

        complete_evaluation

        expect(page).to have_content(/Evaluation has \d+ errors/)
        expect(page).to have_content("Please review and complete all required fields for the evaluation.")
      end

      it 'allows entering scores for evaluation criteria' do
        skip "Add calculated and total score display tests"
        visit new_submission_evaluation_path(submission)

        fill_in_all_scores

        # TODO: Fix this when updating test
        total_score = 0
        expect(page).to have_content(total_score)
      end

      it 'submits the form and marks the evaluation as complete', bullet: :dont_raise do
        visit new_submission_evaluation_path(submission)

        fill_in_all_scores
        complete_evaluation

        expect(page).to have_content('Evaluation is Complete')
      end

      it 'shows the submission details panel' do
        visit new_submission_evaluation_path(submission)
        expect(page).to have_css('[data-controller="hotdog"]')
        expect(page).to have_content(submission.submitter.email)
      end

      it "does not show the identity verification banner" do
        visit phases_path

        expect(page).to have_no_css(".usa-alert--info",
                                    text: "To view submission information on Challenge.gov, you must verify your identity with Login.gov")
      end
    end

    context "with a non-gov email" do
      before do
        evaluator.update(email: generate_user_email(type: :non_gov))
      end

      it 'hides the submission details panel' do
        visit new_submission_evaluation_path(submission)

        expect(page).to have_no_css('[data-controller="hotdog"]')
        expect(page).to have_no_content(submission.submitter.email)
      end

      it "shows the identity verification banner if not ial_level 2" do
        visit phases_path

        expect(page).to have_css(".usa-alert--info",
                                 text: "To view submission information on Challenge.gov, you must verify your identity with Login.gov")
      end

      it "does not show the identity verification banner if ial_level 2" do
        evaluator.update(ial_level: 2)
        visit phases_path

        expect(page).to have_no_css(".usa-alert--info",
                                    text: "To view submission information on Challenge.gov, you must verify your identity with Login.gov")
      end
    end
  end

  def fill_in_all_scores
    all('[data-controller="evaluation-score"]').each do |evaluation_score|
      select_score(evaluation_score)
      comment = Faker::Lorem.sentence(word_count: 3)
      fill_in_comment(evaluation_score, comment)
    end
  end

  def select_score(evaluation_score)
    scoring_type = evaluation_score[:'data-scoring-type']
    max_points = evaluation_score[:'data-points'].to_i
    option_range_start = evaluation_score[:'data-option-range-start']
    option_range_end = evaluation_score[:'data-option-range-end']

    case scoring_type
    when "numeric"
      value = rand(0..max_points)
      fill_in_numeric_input(evaluation_score, value)
    when "binary"
      options = [0, 1]
      value = options.sample
      select_binary_option(evaluation_score, value)
    when "rating"
      options = (option_range_start.to_i..option_range_end.to_i).to_a
      value = options.sample
      select_rating_option(evaluation_score, value)
    end
  end

  def fill_in_numeric_input(evaluation_score, value)
    input = evaluation_score.find('input[type="number"]', visible: :all)

    input.fill_in with: value
  end

  def select_binary_option(evaluation_score, value)
    inputs = evaluation_score.all('input[type="radio"]', visible: :all)
    selected_input = inputs.find { |input| input[:value] == value.to_s }
    label = evaluation_score.find("label[for='#{selected_input[:id]}']", visible: :all)

    label.click
  end

  def select_rating_option(evaluation_score, value)
    inputs = evaluation_score.all('input[type="radio"]', visible: :all)
    selected_input = inputs.find { |input| input[:value] == value.to_s }
    label = evaluation_score.find("label[for='#{selected_input[:id]}']", visible: :all)

    label.click
  end

  def fill_in_comment(evaluation_score, value)
    textarea = evaluation_score.find('textarea', visible: :all)

    textarea.fill_in with: value
  end

  def save_evaluation_draft
    click_button 'Save Draft'
  end

  def complete_evaluation
    click_button 'Complete Evaluation'

    assert_selector 'dialog#complete', visible: true

    within 'dialog#complete' do
      click_link_or_button 'Yes'
    end
  end
end
