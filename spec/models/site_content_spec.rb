# == Schema Information
#
# Table name: site_content
#
#  id            :bigint           not null, primary key
#  section       :string(255)
#  content       :text
#  content_delta :text
#  start_date    :datetime
#  end_date      :datetime
#
require 'rails_helper'

RSpec.describe SiteContent, type: :model do
  describe ".site_wide_banner" do
    it "returns the site_wide_banner content" do
      content = SiteContent.create(section: "site_wide_banner", content: "<p>Test Content</p>")
      expect(SiteContent.site_wide_banner).to eq(content)
    end
    it "returns nil if no site_wide_banner content exists" do
      SiteContent.create(section: "other_section", content: "Test other section content")
      expect(SiteContent.site_wide_banner).to be_nil
    end
  end

  describe "#active?" do
    it "returns false if start_date is nil" do
      content = SiteContent.new(start_date: nil, end_date: DateTime.current + 1.day)
      expect(content.active?).to be false
    end
    it "returns false if end_date is nil" do
      content = SiteContent.new(start_date: DateTime.current - 1.day, end_date: nil)
      expect(content.active?).to be false
    end
    it "returns false if content is blank" do
      content = SiteContent.new(start_date: DateTime.current - 1.day, end_date: DateTime.current + 1.day, content: nil)
      expect(content.active?).to be false
    end
    it "returns false if current time is before start_date" do
      content = SiteContent.new(start_date: DateTime.current + 1.day, end_date: DateTime.current + 2.days)
      expect(content.active?).to be false
    end
    it "returns false if current time is after end_date" do
      content = SiteContent.new(start_date: DateTime.current - 2.days, end_date: DateTime.current - 1.day)
      expect(content.active?).to be false
    end
    it "returns true if current time is between start_date and end_date" do
      content = SiteContent.new(start_date: DateTime.current - 1.day, end_date: DateTime.current + 1.day, content: "<h1>Test Content</h1>")
      expect(content.active?).to be true
    end
  end
end
