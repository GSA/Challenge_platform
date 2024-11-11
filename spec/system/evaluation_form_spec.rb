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

      fill_in_full_form

      save_form

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

def fill_in_full_form
  fill_in_base_form_info
  fill_in_all_eval_criteria_types
end

def fill_in_base_form_info
  # Fill in main form fields
  fill_in_title("New Evaluation Form")
  select_phase(challenge.phases.first)
  fill_in_instructions("Example instructions")
  check_require_comments
  select_scale_type("point")
  fill_in_end_date(challenge.phases.first.end_date + 1)
end

def fill_in_all_eval_criteria_types
  fill_in_numeric_criteria_type
  fill_in_binary_criteria_type
  fill_in_rating_criteria_type
end

def fill_in_numeric_criteria_type
  # Fill in initial criterion
  index = 0
  fill_in_criterion_title(index, "New Numeric Evaluation Criterion")
  fill_in_criterion_description(index, "Example criterion description")
  fill_in_criterion_points_weight(index, "10")
  select_criterion_scoring_type(index, "numeric")
end

def fill_in_binary_criteria_type
  # Add new criterion (binary scoring type) and fill in
  index = add_criterion
  fill_in_criterion_title(index, "New Binary Evaluation Criterion")
  fill_in_criterion_description(index, "Example criterion description")
  fill_in_criterion_points_weight(index, "10")
  select_criterion_scoring_type(index, "binary")
  fill_in_criterion_option_label(index, 0, "No")
  fill_in_criterion_option_label(index, 1, "Yes")
end

def fill_in_rating_criteria_type
  # Add new criterion (rating scoring type) and fill in
  index = add_criterion
  fill_in_criterion_title(index, "New Rating Evaluation Criterion")
  fill_in_criterion_description(index, "Example criterion description")
  fill_in_criterion_points_weight(index, "10")
  select_criterion_scoring_type(index, "rating")
  select_option_range_start(index, 1)
  select_option_range_end(index, 5)
  fill_in_criterion_option_label(index, 1, "Disagree")
  fill_in_criterion_option_label(index, 2, "Slightly Disagree")
  fill_in_criterion_option_label(index, 3, "Neutral")
  fill_in_criterion_option_label(index, 4, "Slightly Agree")
  fill_in_criterion_option_label(index, 5, "Agree")
end

# Form Fill Helpers
def fill_in_title(value)
  fill_in 'evaluation_form[title]', with: value
end

def select_phase(phase)
  challenge_phase_title = challenge_phase_title(phase.challenge, phase)
  find_by_id('challenge-combo').click
  find('#challenge-combo--list li', text: challenge_phase_title).click
end

def fill_in_instructions(value)
  fill_in 'evaluation_form[instructions]', with: value
end

def check_require_comments
  find("label[for='evaluation_form_comments_required']").click
end

def select_scale_type(scale_type)
  allowed_scale_types = %w[point weight]
  unless allowed_scale_types.include?(scale_type)
    raise ArgumentError, "Invalid scale type: #{scale_type}. Allowed values are: #{allowed_scale_types.join(', ')}"
  end

  find("label[for='#{scale_type}_scale']").click
end

def fill_in_criterion_title(index, value)
  fill_in "evaluation_form[evaluation_criteria_attributes][#{index}][title]", with: value
end

def fill_in_criterion_description(index, value)
  fill_in "evaluation_form[evaluation_criteria_attributes][#{index}][description]", with: value
end

def fill_in_criterion_points_weight(index, value)
  fill_in "evaluation_form[evaluation_criteria_attributes][#{index}][points_or_weight]", with: value
end

def select_criterion_scoring_type(index, scoring_type)
  allowed_scoring_types = %w[numeric rating binary]
  unless allowed_scoring_types.include?(scoring_type)
    raise ArgumentError,
          "Invalid scoring type: #{scoring_type}. Allowed values are: #{allowed_scoring_types.join(', ')}"
  end

  find("label[for='evaluation_form_evaluation_criteria_attributes_#{index}_scoring_type_#{scoring_type}']").click
end

def add_criterion
  click_link_or_button "add-criteria-button"
  # Returns the last visible criterion index (most recently added)
  visible_criterion_indicies[-1]
end

def remove_criterion(index)
  click_link_or_button "evaluation_form_evaluation_criteria_attributes_#{index}_delete_criteria"
end

def visible_criterion_indicies
  all('.criteria-row').map.with_index { |_element, index| index }
end

def select_option_range_start(index, value)
  select value, from: "evaluation_form[evaluation_criteria_attributes][#{index}][option_range_start]"
end

def select_option_range_end(index, value)
  select value, from: "evaluation_form[evaluation_criteria_attributes][#{index}][option_range_end]"
end

def fill_in_criterion_option_label(criterion_index, label_index, value)
  fill_in "evaluation_form[evaluation_criteria_attributes][#{criterion_index}][option_labels][#{label_index}]",
          with: value
end

# TODO: This might need to go a month ahead if the date isn't found initially
def fill_in_end_date(date)
  date = date.strftime("%Y-%m-%d")
  find(".usa-date-picker__button").click
  find(".usa-date-picker__calendar__date[data-value='#{date}']").click
end

def save_form
  click_link_or_button 'Save'
end
