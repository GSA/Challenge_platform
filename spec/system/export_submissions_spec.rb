require 'rails_helper'

RSpec.describe "Export Submissions", :js, type: :system do
  let(:user) { create_user(role: "challenge_manager", status: "active") }
  let(:challenge) { create(:challenge) }
  let(:phase) { create(:phase, challenge: challenge) }
  let(:evaluator) { create(:user, role: 'evaluator') }
  let!(:submission) { create(:submission, phase: phase) }
  let!(:evaluation_form) do
    create(:evaluation_form, phase: phase, challenge: challenge, closing_date: 1.month.from_now)
  end

  before do
    ChallengeManager.create!(user: user, challenge: challenge)
    ChallengePhasesEvaluator.create!(challenge: challenge, phase: phase, user: evaluator)

    system_login_user(user)
    visit submissions_phase_path(phase)
  end

  it "shows alert when no export options are selected", :js do
    find("[data-action='click->export-submissions#open']").click

    message = accept_alert do
      find("[data-action='click->export-submissions#exportSubmissions']").click
    end

    expect(message).to eq("Please select at least one export option")
  end

  it "successfully exports submissions CSV", :js do
    find("[data-action='click->export-submissions#open']").click

    within('dialog[open]') do
      check 'submissions-csv', allow_label_click: true
      find("[data-action='click->export-submissions#exportSubmissions']").click
    end

    expect(page).to have_no_css('dialog[open]')
  end

  it "successfully exports evaluations CSV", :js do
    find("[data-action='click->export-submissions#open']").click

    within('dialog[open]') do
      check 'evaluations-csv', allow_label_click: true
      find("[data-action='click->export-submissions#exportSubmissions']").click
    end

    expect(page).to have_no_css('dialog[open]')
  end

  it "successfully exports both submissions and evaluations CSV", :js do
    find("[data-action='click->export-submissions#open']").click

    within('dialog[open]') do
      check 'submissions-csv', allow_label_click: true
      check 'evaluations-csv', allow_label_click: true
      find("[data-action='click->export-submissions#exportSubmissions']").click
    end

    expect(page).to have_no_css('dialog[open]')
  end

  context "with a non gov email" do
    before do
      user.update(email: generate_user_email(type: :non_gov))
    end

    it 'redirects away from phase submissions page' do
      visit submissions_phase_path(phase)

      assert_current_path phases_path
      expect(page).to have_css('.usa-alert', text: I18n.t("access_denied"))
      expect(page).to(be_axe_clean)
    end

    it 'displays error alert if triggered' do
      find("[data-action='click->export-submissions#open']").click

      within('dialog[open]') do
        check 'submissions-csv', allow_label_click: true
        find("[data-action='click->export-submissions#exportSubmissions']").click
      end

      expect do
        accept_alert("Export failed. Please try again.")
      end.not_to raise_error
    end
  end
end
