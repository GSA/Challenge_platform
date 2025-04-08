# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "SiteWideBanner" do
  let(:active_site_wide_banner) {
    SiteContent.create(
      section: 'site_wide_banner',
      content: '<h2>Test Banner</h2>',
      start_date: DateTime.current - 1.day,
      end_date: DateTime.current + 1.day
    )
  }
  let(:future_site_wide_banner) {
    SiteContent.create(
      section: 'site_wide_banner',
      content: '<h2>Test Banner</h2>',
      start_date: DateTime.current + 1.day,
      end_date: DateTime.current + 7.day
    )
  }
  let(:expired_site_wide_banner) {
    SiteContent.create(
      section: 'site_wide_banner',
      content: '<h2>Test Banner</h2>',
      start_date: DateTime.current - 7.day,
      end_date: DateTime.current - 1.day
    )
  }

  context "when logged in as a challenge manager" do
    before { create_and_log_in_user(role: "challenge_manager") }

    it "with no banner renders the page with no alert box" do
      get "/phases"
      expect(response.body).not_to have_css('.usa-alert.site-wide-banner')
    end

    context "with an active banner" do
      before { active_site_wide_banner }

      it "renders the page with an alert box" do
        get "/phases"
        expect(response.body).to have_css('.usa-alert.site-wide-banner')
        expect(response.body).to have_css('h2', text: 'Test Banner')
      end
    end

    context "with a future banner" do
      before { future_site_wide_banner }

      it "does not render the banner" do
        get "/phases"
        expect(response.body).not_to have_css('.usa-alert.site-wide-banner')
      end
    end

    context "with an expired banner" do
      before { expired_site_wide_banner }

      it "does not render the banner" do
        get "/phases"
        expect(response.body).not_to have_css('.usa-alert.site-wide-banner')
      end
    end
  end

  context "when logged in as an evaluator" do
    before { create_and_log_in_user(role: "evaluator", status: :active) }

    context "with no active banner" do
      it "renders the page with no alert box" do
        get "/evaluations"
        expect(response.body).not_to have_css('.usa-alert.site-wide-banner')
      end
    end

    context "with an active banner" do
      before { active_site_wide_banner }

      it "renders the page with an alert box" do
        get "/evaluations"
        expect(response.body).to have_css('.usa-alert.site-wide-banner')
        expect(response.body).to have_css('h2', text: 'Test Banner')
      end
    end

    context "with a future banner" do
      before { future_site_wide_banner }

      it "does not render the banner" do
        get "/evaluations"
        expect(response.body).not_to have_css('.usa-alert.site-wide-banner')
      end
    end

    context "with an expired banner" do
      before { expired_site_wide_banner }

      it "does not render the banner" do
        get "/evaluations"
        expect(response.body).not_to have_css('.usa-alert.site-wide-banner')
      end
    end
  end
end
