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

    it 'moves focus to main content when using keyboard' do
      if !page.has_css?('a.usa-skipnav', visible: false)
        # saving a screenshot seems to force the page to render, or delays enough for the element to be hidden
        page.save_screenshot('skip_to_main_content_focus_1.png')
        # wait for the element to be hidden by USWDS css
        expect(page).to have_css('a.usa-skipnav', visible: false)
      end
      find('body').send_keys(:tab)
      if !page.has_css?('a.usa-skipnav', visible: true)
        # saving a screenshot seems to force the page to render, or delays enough for the element to be visible
        page.save_screenshot('skip_to_main_content_focus_2.png')
        # wait for the element to be visible by tabbing to it
        expect(page).to have_css('a.usa-skipnav', text: 'Skip to main content')
      end
      find('a.usa-skipnav').send_keys(:return)
      expect(page.evaluate_script('document.activeElement.id')).to eq('main-content')
    end
  end
end
