require 'rails_helper'

RSpec.describe 'Evaluation Form', :js, type: :system do
  let(:user) { create_user(role: "challenge_manager") }

  before do
    system_login_user(user) if user
  end

  describe "new evaluation form page" do
    it "is accessible" do
      visit new_evaluation_form_path
      expect(page).to(be_axe_clean)
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
