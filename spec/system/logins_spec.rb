# frozen_string_literal: true

require 'rails_helper'

describe "Site Accessibility", :js, type: :system do
  it "web root page is a11y compliant" do
    visit "/"

    expect(page).to(be_axe_clean)
  end

  it "dashboard index page is a11y compliant" do
    visit dashboard_path

    expect(page).to(be_axe_clean)
  end
end
