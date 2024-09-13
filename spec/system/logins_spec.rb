# frozen_string_literal: true

require 'rails_helper'

describe "A11y", :js do
  it "web root page is accessible" do
    visit "/"

    expect(page).to(be_axe_clean)
  end

  it "dashboard index page is accessible" do
    visit dashboard_path

    expect(page).to(be_axe_clean)
  end
end
