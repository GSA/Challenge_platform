require 'rails_helper'

RSpec.describe 'Evaluation Form', :js, type: :system do
  let(:user) { create_user(role: "challenge_manager") }

  before do
    system_login_user(user) if user
  end

  describe "new evaluation form page" do
    let(:challenge) { create(:challenge, user:) }

    before do
      challenge.reload
    end

    it "is accessible" do
      visit new_evaluation_form_path
      expect(page).to(be_axe_clean)
    end

    it 'allows creation of a valid form' do
      visit new_evaluation_form_path

      # Fill in title
      fill_in 'evaluation_form[title]', with: 'New Evaluation Form'

      # Select phase
      phase = challenge.phases.first
      challenge_phase_title = challenge_phase_title(challenge, phase)
      find_by_id('challenge-combo').click
      find('#challenge-combo--list li', text: challenge_phase_title).click

      # Fill in instructions
      fill_in 'evaluation_form[instructions]', with: 'Example instructions'

      # Check required comments box
      find("label[for='evaluation_form_comments_required']").click

      # Select scale type radio button
      find("label[for='point_scale']").click

      # Fill in initial criteria title
      fill_in 'evaluation_form[evaluation_criteria_attributes][0][title]', with: 'New Evaluation Criteria'

      # Fill in initial criteria description
      fill_in 'evaluation_form[evaluation_criteria_attributes][0][description]', with: 'Example criteria description'

      # Fill in initial criteria points/weight
      fill_in 'evaluation_form[evaluation_criteria_attributes][0][points_or_weight]', with: '10'

      # Fill in initial criteria scoring type
      find("label[for='evaluation_form_evaluation_criteria_attributes_0_scoring_type_numeric']").click

      # Fill in end date with datepicker
      find(".usa-date-picker__button").click
      date = (phase.end_date + 1).strftime("%Y-%m-%d")
      find(".usa-date-picker__calendar__date[data-value='#{date}']").click

      click_on 'Save'

      expect(page).to have_content('Evaluation Form Saved')
    end
  end

  describe "update evaluation form page" do
    let(:challenge) { create(:challenge, user: user) }
    let(:evaluation_form) { create(:evaluation_form, challenge: challenge) }

    it "is accessible" do
      visit edit_evaluation_form_path(evaluation_form)
      expect(page).to(be_axe_clean)
    end
  end

  describe "evaluation form confirmation page" do
    it "is accessible" do
      visit evaluation_forms_confirmation_path
      expect(page).to(be_axe_clean)
    end
  end
end
