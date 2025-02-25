# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Skip to main content navigation', :js, type: :system do
  let(:user) { create_user(role: "challenge_manager") }

  before do
    system_login_user(user)
  end

  context "when on phases index page" do
    before { visit phases_path }

    it 'is hidden by default but present in the DOM' do
      expect(page).to have_css('.usa-skipnav', visible: false)
    end

    it 'becomes visible when focused via keyboard tab' do
      find('body').send_keys(:tab)
      expect(page).to have_css('.usa-skipnav', visible: true)
    end

    it 'moves focus to main content when using keyboard' do
      find('body').send_keys(:tab)
      find('.usa-skipnav', visible: true).send_keys(:return)
      expect(page.evaluate_script('document.activeElement.id')).to eq('main-content')
    end
  end
end
