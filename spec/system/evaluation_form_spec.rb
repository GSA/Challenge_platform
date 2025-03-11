require 'rails_helper'

RSpec.describe 'Evaluation Form', :js, type: :system do
  let(:user) { create_user(role: "challenge_manager", status: "active") }
  let!(:challenge) { create(:challenge, user:, is_multi_phase: true) }
  let!(:phase) { create(:phase, challenge: challenge) }

  describe "new evaluation form page" do
    before do
      system_login_user(user)
    end

    it "is accessible" do
      visit new_phase_evaluation_form_path(phase)
      # Accessibility check on empty form
      expect(page).to(be_axe_clean)
    end

    it "shows a confirmation modal when clicking the cancel button" do
      visit new_phase_evaluation_form_path(phase)

      click_link_or_button "Cancel"

      assert_selector 'dialog#cancel', visible: true

      expect(page).to(be_axe_clean)
    end

    it "redirects to phases path when clicking yes in cancel modal" do
      visit new_phase_evaluation_form_path(phase)

      click_link_or_button "Cancel"

      assert_selector 'dialog#cancel', visible: true

      within 'dialog#cancel' do
        click_link_or_button 'Yes'
      end

      assert_current_path phases_path
    end

    it "closes the cancel modal and does nothing if you click close" do
      visit new_phase_evaluation_form_path(phase)

      click_link_or_button "Cancel"

      assert_selector 'dialog#cancel', visible: true

      within 'dialog#cancel' do
        click_link_or_button 'Close'
      end

      assert_no_selector 'dialog#cancel', visible: true
      assert_current_path new_phase_evaluation_form_path(phase)
    end

    it 'allows creation of a valid form with all 3 criteria scoring types' do
      visit new_phase_evaluation_form_path(phase)

      fill_in_full_form

      # Check accessibility with some collapsed criteria
      check_criteria_accordion_expanded(0, false)
      expect(page).to(be_axe_clean)

      # Open all criterion accordion then check accessibility
      toggle_all_criteria_accordions
      expect(page).to(be_axe_clean)

      save_form

      expect(page).to have_content("Evaluation form is saved")

      # Should be on phases index view
      evaluation_form = EvaluationForm.first
      phase = evaluation_form.phase
      challenge_phase_title = challenge_phase_title(phase.challenge, phase)
      expect(page).to have_content(challenge_phase_title)
      expect(page).to have_content("Edit form")
      expect(page).to have_link("Edit form", href: edit_phase_evaluation_form_path(phase, evaluation_form))

      # Check accessibility
      expect(page).to(be_axe_clean)
    end

    it "contains the evaluation form data when editing after creation" do
      visit new_phase_evaluation_form_path(phase)
      fill_in_full_form
      save_form
      expect(page).to have_link("Edit form")
      evaluation_form = phase.evaluation_form
      click_link("Edit form", href: edit_phase_evaluation_form_path(evaluation_form.phase, evaluation_form))
      expect_form_to_match_all_evaluation_form_values(evaluation_form)
    end

    it 'allows removing evaluation criteria' do
      visit new_phase_evaluation_form_path(phase)

      fill_in_full_form

      # Starts with 3
      expect(visible_criterion_indicies.length).to eq(3)
      toggle_criteria_accordion(0)
      expect(page).to have_content("Remove Criteria 1")
      remove_criterion(0)

      expect(visible_criterion_indicies.length).to eq(2)
      toggle_criteria_accordion(1)
      expect(page).to have_content("Remove Criteria 2")
      remove_criterion(1)

      # Being on the last criteria hides the remove criteria button
      expect(visible_criterion_indicies.length).to eq(1)
      expect(page).to have_no_css("button.delete-criteria-button")
      expect(page).to have_no_content("Remove Criteria")
      expect(visible_criterion_indicies).to include(2)
    end

    it "shows an error if criteria points don't add up to 100 for weighted form" do
      visit new_phase_evaluation_form_path(phase)

      fill_in_base_form_info
      select_scale_type("weighted")

      # Fill in two criteria with only 20 points
      fill_in_numeric_criteria_type(initial: true)
      fill_in_criterion_points_weight(0, 10)
      fill_in_numeric_criteria_type
      fill_in_criterion_points_weight(1, 10)

      save_form
      expect(page).to have_content(I18n.t("evaluation_form.errors.criteria_weight_total"))

      # Fix weights to add up to 100 and form should submit
      fill_in_criterion_points_weight(0, 50)
      fill_in_criterion_points_weight(1, 50)

      save_form
      expect(page).to have_content("Evaluation form is saved")
    end

    it "expands all criteria if switching to weighted scale with value over 100" do
      visit new_phase_evaluation_form_path(phase)

      fill_in_base_form_info
      select_scale_type("point")

      # Fill in criteria with one being over 100
      fill_in_numeric_criteria_type(initial: true)
      fill_in_criterion_points_weight(0, 10)
      fill_in_numeric_criteria_type
      fill_in_criterion_points_weight(1, 101)
      fill_in_numeric_criteria_type
      fill_in_criterion_points_weight(2, 102)

      toggle_all_criteria_accordions(open: false)

      check_criteria_accordion_expanded(0, false)
      check_criteria_accordion_expanded(1, false)
      check_criteria_accordion_expanded(2, false)

      select_scale_type("weighted")

      save_form

      check_criteria_accordion_expanded(0, true)
      check_criteria_accordion_expanded(1, true)
      check_criteria_accordion_expanded(2, true)

      # Scale type should be weighted
      expect_form_scale_type_to_equal("weight")
    end

    it "does nothing if switching to weighted scale with no value over 100" do
      visit new_phase_evaluation_form_path(phase)

      fill_in_base_form_info
      select_scale_type("point")

      # Fill in criteria with one being over 100
      fill_in_numeric_criteria_type(initial: true)
      fill_in_criterion_points_weight(0, 10)
      fill_in_numeric_criteria_type
      fill_in_criterion_points_weight(1, 100)

      toggle_all_criteria_accordions(open: false)

      check_criteria_accordion_expanded(0, false)
      check_criteria_accordion_expanded(1, false)

      select_scale_type("weighted")

      check_criteria_accordion_expanded(0, false)
      check_criteria_accordion_expanded(1, false)

      # Scale type should be weighted
      expect_form_scale_type_to_equal("weight")
      expect_criterion_points_or_weight_to_equal(0, 10)
      expect_criterion_points_or_weight_to_equal(1, 100)
    end
  end

  describe "update evaluation form page" do
    # let(:challenge) do
    #   create(:challenge, user:, is_multi_phase: true)
    # end
    let(:evaluation_form) do
      create(:evaluation_form, challenge:, phase: phase, scale_type: "weight")
    end

    before do
      system_login_user(user)
    end

    it "is accessible" do
      visit edit_phase_evaluation_form_path(evaluation_form.phase, evaluation_form)
      expect(page).to(be_axe_clean)
    end

    it "shows a confirmation modal when clicking the cancel button" do
      visit edit_phase_evaluation_form_path(evaluation_form.phase, evaluation_form)

      click_link_or_button "Cancel"

      assert_selector 'dialog#cancel', visible: true

      expect(page).to(be_axe_clean)
    end

    it "redirects to evaluation form path when clicking yes in cancel modal" do
      visit edit_phase_evaluation_form_path(evaluation_form.phase, evaluation_form)

      click_link_or_button "Cancel"

      assert_selector 'dialog#cancel', visible: true

      within 'dialog#cancel' do
        click_link_or_button 'Yes'
      end

      assert_current_path phases_path
    end

    it "closes the cancel modal and does nothing if you click close" do
      visit edit_phase_evaluation_form_path(evaluation_form.phase, evaluation_form)

      click_link_or_button "Cancel"

      assert_selector 'dialog#cancel', visible: true

      within 'dialog#cancel' do
        click_link_or_button 'Close'
      end

      assert_no_selector 'dialog#cancel', visible: true
      assert_current_path edit_phase_evaluation_form_path(evaluation_form.phase, evaluation_form)
    end

    it 'allows editing of an existing form values' do
      visit edit_phase_evaluation_form_path(evaluation_form.phase, evaluation_form)

      # Prep updated form field values for comparison
      # TODO: Might affect disabled state, start_date, etc.
      updated_instructions = "Updated #{evaluation_form.instructions}"
      updated_comments_required = !evaluation_form.comments_required
      # TODO: Enable this when criteria updating and weight fixing is implemented
      # updated_scale_type = !evaluation_form.weighted_scoring
      updated_end_date = evaluation_form.closing_date + 1.day

      # Update form field values
      fill_in_instructions(updated_instructions)
      check_comments_required
      # TODO: When switching to weighted it needs to make sure criteria values sum to 100
      # select_scale_type(updated_scale_type ? "point" : "weighted")
      fill_in_end_date(updated_end_date)

      save_form
      expect(page).to have_current_path(phases_path)
      expect(page).to have_content("Evaluation form is saved")

      evaluation_form.reload
      expect(evaluation_form.instructions).to eq(updated_instructions)
      expect(evaluation_form.comments_required).to eq(updated_comments_required)
      # TODO: Enable this when weighted scoring issue above is solved
      # expect(evaluation_form.weighted_scoring).to eq(updated_scale_type)
      expect(evaluation_form.closing_date).to eq(updated_end_date)
    end

    it 'allows adding new criteria' do
      visit edit_phase_evaluation_form_path(evaluation_form.phase, evaluation_form)

      num_criteria = evaluation_form.evaluation_criteria.length

      # Create 3 new criteria of each type
      fill_in_numeric_criteria_type
      fill_in_rating_criteria_type
      fill_in_binary_criteria_type

      # Make sure criteria are expanded so they can be edited if needed
      toggle_all_criteria_accordions

      rebalance_criteria_weights if evaluation_form.weighted_scoring?
      save_form
      expect(page).to have_content("Evaluation form is saved")

      expect(evaluation_form.reload.evaluation_criteria.length).to eq(num_criteria + 3)
    end

    it 'allows removing existing criteria' do
      visit edit_phase_evaluation_form_path(phase, evaluation_form)

      num_criteria = evaluation_form.evaluation_criteria.length

      # Add a criterion in case there is only 1 remaining
      fill_in_numeric_criteria_type

      # Make sure criteria are expanded so they can be edited if needed
      toggle_all_criteria_accordions

      # Remove an existing criterion from the form
      remove_criterion(visible_criterion_indicies[0])

      rebalance_criteria_weights if evaluation_form.weighted_scoring?
      save_form
      expect(page).to have_content("Evaluation form is saved")

      evaluation_form.reload
      # Criteria count should be the same since one was added and removed
      expect(evaluation_form.evaluation_criteria.length).to eq(num_criteria)
    end

    it 'disables all fields except end date after start date' do
      closed_challenge = create(:challenge, user:, phases: [create(:phase, end_date: 1.week.ago)])
      closed_evaluation_form = create(:evaluation_form, challenge:, phase: closed_challenge.phases.first)

      visit edit_phase_evaluation_form_path(closed_evaluation_form.phase, closed_evaluation_form)

      # Add expectation in spec to satisfy rubocop
      expect(page).to have_css("form[data-controller='evaluation-form modal form-validation']")
      check_all_non_hidden_inputs_disabled_except_end_date
    end
  end

  describe "evaluation form confirmation page" do
    let(:evaluation_form) do
      challenge = create(:challenge, user:, is_multi_phase: true)
      create(:evaluation_form, challenge:, phase: challenge.phases.first, scale_type: "weight")
    end

    before do
      system_login_user(user)
    end

    it "is accessible" do
      visit confirmation_phase_evaluation_form_path(evaluation_form.phase, evaluation_form)
      expect(page).to have_content("Evaluation Form Saved")
      expect(page).to(be_axe_clean)
    end
  end
end

#######################################
############### Helpers ###############
#######################################

##### Form Fill Helpers #####
def fill_in_full_form
  fill_in_base_form_info
  fill_in_all_eval_criteria_types
end

def fill_in_base_form_info
  # Fill in main form fields
  fill_in_instructions("Example instructions")
  check_comments_required
  select_scale_type("point")
  fill_in_end_date(phase.end_date + 1)
end

def fill_in_all_eval_criteria_types
  fill_in_numeric_criteria_type(initial: true)
  fill_in_binary_criteria_type
  fill_in_rating_criteria_type
end

def fill_in_numeric_criteria_type(initial: false)
  index = initial ? 0 : add_criterion

  fill_in_criterion_title(index, "Criterion #{Faker::Lorem.sentence(word_count: 3)}")
  fill_in_criterion_description(index, "Example criterion description")
  fill_in_criterion_points_weight(index, "10")
  select_criterion_scoring_type(index, "numeric")
end

def fill_in_binary_criteria_type(initial: false)
  index = initial ? 0 : add_criterion

  fill_in_criterion_title(index, "Criterion #{Faker::Lorem.sentence(word_count: 3)}")
  fill_in_criterion_description(index, "Example criterion description")
  fill_in_criterion_points_weight(index, "10")
  select_criterion_scoring_type(index, "binary")
  fill_in_criterion_option_label(index, 0, "No")
  fill_in_criterion_option_label(index, 1, "Yes")
end

def fill_in_rating_criteria_type(initial: false)
  index = initial ? 0 : add_criterion

  fill_in_criterion_title(index, "Criterion #{Faker::Lorem.sentence(word_count: 3)}")
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

def fill_in_instructions(value)
  fill_in 'evaluation_form[instructions]', with: value
end

def check_comments_required
  find("label[for='evaluation_form_comments_required']").click
end

def select_scale_type(scale_type)
  allowed_scale_types = %w[point weighted]
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
  expect(page).to have_css("button.delete-criteria-button")
  click_link_or_button "evaluation_form_evaluation_criteria_attributes_#{index}_delete_criteria"

  assert_selector 'dialog#remove-criteria', visible: true

  within 'dialog#remove-criteria' do
    click_link_or_button 'Yes'
  end
end

def toggle_criteria_accordion(index)
  find("button[aria-controls='evaluation_form_evaluation_criteria_attributes_#{index}_accordion']").click
end

# False to close all, true to open all
def toggle_all_criteria_accordions(open: true)
  visible_criterion_indicies.each do |index|
    if open
      toggle_criteria_accordion(index) unless get_criteria_accordion_state(index)
    elsif get_criteria_accordion_state(index)
      toggle_criteria_accordion(index)
    end
  end
end

# Returns false if closed, true if open
def get_criteria_accordion_state(index)
  button_selector = "button[aria-controls='evaluation_form_evaluation_criteria_attributes_#{index}_accordion']"
  find(button_selector)[:'aria-expanded'] == "true"
end

def check_criteria_accordion_expanded(index, state)
  button_selector = "button[aria-controls='evaluation_form_evaluation_criteria_attributes_#{index}_accordion']"
  button_state_selector = "#{button_selector}[aria-expanded='#{state}']"
  expect(page).to have_selector(button_state_selector)

  accordion_content = find("#evaluation_form_evaluation_criteria_attributes_#{index}_accordion", visible: :all)
  if state
    expect(accordion_content).to be_visible
  else
    expect(accordion_content).not_to be_visible
  end
end

def visible_criterion_indicies
  all('.criteria-row').map { |element| element["data-index"].to_i }
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

def fill_in_end_date(date)
  date_string = date.strftime("%Y-%m-%d")

  find(".usa-date-picker__button").click
  # Ensure proper year is focused in calendar
  find(".usa-date-picker__calendar__year-selection").click
  find(".usa-date-picker__calendar__year[data-value='#{date.year}']").click
  # Ensure proper month is focused in calendar
  find(".usa-date-picker__calendar__month-selection").click
  find(".usa-date-picker__calendar__month[data-value='#{date.month - 1}']").click

  # Select date from calendar
  find(".usa-date-picker__calendar__date[data-value='#{date_string}']").click
end

def save_form
  click_on 'Save'
end

##### Form Focus Helpers #####
# Checks for form fields being focused. Usually in the case of a required field not filled out
# Includes non visible fields because of custom checkbox and radio button styling
def expect_field_to_be_focused(selector)
  expect(page).to have_css("#{selector}:focus", visible: :all)
end

def expect_form_instructions_to_be_focused
  selector = "textarea[name='evaluation_form[instructions]']"
  expect_field_to_be_focused(selector)
end

def expect_form_scale_type_to_be_focused
  selector = "input#point_scale"
  expect_field_to_be_focused(selector)
end

def expect_form_end_date_to_be_focused
  selector = "input[name='evaluation_form[closing_date]']"
  expect_field_to_be_focused(selector)
end

def expect_criterion_title_to_be_focused(index)
  selector = "input[name='evaluation_form[evaluation_criteria_attributes][#{index}][title]']"
  expect_field_to_be_focused(selector)
end

def expect_criterion_description_to_be_focused(index)
  selector = "textarea[name='evaluation_form[evaluation_criteria_attributes][#{index}][description]']"
  expect_field_to_be_focused(selector)
end

def expect_criterion_points_or_weight_to_be_focused(index)
  selector = "input[name='evaluation_form[evaluation_criteria_attributes][#{index}][points_or_weight]']"
  expect_field_to_be_focused(selector)
end

def expect_criterion_scoring_type_to_be_focused(index)
  selector = "#evaluation_form_evaluation_criteria_attributes_#{index}_scoring_type_numeric"
  expect_field_to_be_focused(selector)
end

def expect_criterion_option_label_to_be_focused(criterion_index, label_index)
  selector =
    "input[name='evaluation_form[evaluation_criteria_attributes][#{criterion_index}][option_labels][#{label_index}]']"
  expect_field_to_be_focused(selector)
end

##### Form Field Value Helpers #####
def expect_form_to_match_all_evaluation_form_values(evaluation_form)
  expect_base_form_field_to_match(evaluation_form)
  expect_criterion_fields_to_match(evaluation_form)
end

def expect_base_form_field_to_match(evaluation_form)
  expect_form_instructions_to_equal(evaluation_form.instructions)
  expect_form_comments_required_to_equal(evaluation_form.comments_required)
  expect_form_scale_type_to_equal(evaluation_form.scale_type)
  expect_form_end_date_to_equal(evaluation_form.closing_date.strftime("%m/%d/%Y"))
end

def expect_criterion_fields_to_match(evaluation_form)
  evaluation_form.evaluation_criteria.each_with_index do |criterion, index|
    expect_criterion_title_to_equal(index, criterion.title)
    expect_criterion_description_to_equal(index, criterion.description)
    expect_criterion_points_or_weight_to_equal(index, criterion.points_or_weight)
    expect_criterion_scoring_type_to_equal(index, criterion.scoring_type)

    expect_criterion_scoring_type_specific_fields_to_match(index, criterion)
  end
end

def expect_criterion_scoring_type_specific_fields_to_match(index, criterion)
  # Rating specific fields
  if criterion.scoring_type == "rating"
    expect_criterion_option_range_start_to_equal(index, criterion.option_range_start)
    expect_criterion_option_range_end_to_equal(index, criterion.option_range_end)
  end

  # Option labels. Only for rating/binary scoring_types
  return unless criterion.scoring_type != "numeric"

  # expect_criterion_option_labels_to_match(criterion)
  criterion.option_labels.each do |option_index, option_label|
    expect_criterion_option_label_to_equal(index, option_index, option_label)
  end
end

# Base form value checkers
def expect_form_phase_select_to_not_contain(value)
  expect(page).to have_no_select(
    class: "usa-combo-box__select",
    with_options: [value],
    visible: :all
  )
end

def expect_form_phase_select_to_contain(value)
  expect(page).to have_select(
    class: "usa-combo-box__select",
    with_options: [value],
    visible: :all
  )
end

def expect_form_phase_select_to_be_empty
  expect(page).to have_select(
    class: "usa-combo-box__select",
    options: [],
    visible: :all
  )
end

def expect_form_instructions_to_equal(value)
  expect(find_by_id('evaluation_form_instructions').value).to eq(value)
end

def expect_form_comments_required_to_equal(value)
  expect(find_by_id('evaluation_form_comments_required', visible: :all).checked?).to eq(value)
end

def expect_form_scale_type_to_equal(value)
  expect(find("input[name='evaluation_form[scale_type]'][value='#{value}']", visible: :all)).to be_checked
end

def expect_form_end_date_to_equal(value)
  expect(find_by_id('evaluation_form_closing_date').value).to eq(value)
end

# Criterion value checkers. Checks all visibility since accordions can be collapsed
def expect_criterion_title_to_equal(index, value)
  expect(find("#evaluation_form_evaluation_criteria_attributes_#{index}_title", visible: :all).value).to eq(value)
end

def expect_criterion_description_to_equal(index, value)
  expect(find("#evaluation_form_evaluation_criteria_attributes_#{index}_description", visible: :all).value).to eq(value)
end

def expect_criterion_points_or_weight_to_equal(index, value)
  expect(find("#evaluation_form_evaluation_criteria_attributes_#{index}_points_or_weight",
              visible: :all).value.to_i).to eq(value)
end

def expect_criterion_scoring_type_to_equal(index, value)
  scoring_type_radio = find("#evaluation_form_evaluation_criteria_attributes_#{index}_scoring_type_#{value}",
                            visible: :all)
  expect(scoring_type_radio).to be_checked
end

def expect_criterion_option_range_start_to_equal(index, value)
  expect(find("select#evaluation_form_evaluation_criteria_attributes_#{index}_option_range_start",
              visible: :all).value.to_i).to eq(value)
end

def expect_criterion_option_range_end_to_equal(index, value)
  expect(find("select#evaluation_form_evaluation_criteria_attributes_#{index}_option_range_end",
              visible: :all).value.to_i).to eq(value)
end

def expect_criterion_option_label_to_equal(criterion_index, label_index, value)
  expect(find("#evaluation_form_evaluation_criteria_attributes_#{criterion_index}_option_labels_#{label_index}",
              visible: :all).value).to eq(value)
end

##### Misc Form Helpers #####
def rebalance_criteria_weights
  balanced_values = random_values_for_weighted_scoring(visible_criterion_indicies.length)
  visible_criterion_indicies.each_with_index do |crit_index, each_index|
    fill_in_criterion_points_weight(crit_index, balanced_values[each_index])
  end
end

# Checks that all non hidden or end date fields are disabled
def check_all_non_hidden_inputs_disabled_except_end_date
  within("form[data-controller='evaluation-form modal form-validation']") do
    all("input:not([type='hidden']), textarea, select").each do |field|
      if field[:id] == "evaluation_form_closing_date"
        expect(field).not_to be_disabled, "Expected #{field[:id]} to not be disabled"
      else
        expect(field).to be_disabled, "Expected #{field[:id]} to be disabled"
      end
    end
  end
end
