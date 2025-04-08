# frozen_string_literal: true

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
class SiteContent < ApplicationRecord
  self.table_name = 'site_content'

  def self.site_wide_banner
    find_by(section: 'site_wide_banner')
  end

  # Used by temporary content such as the "site_wide_banner"
  # This is used to determine if the content should be displayed.
  # Returns true if the content is present and current.
  # `current` = current time is between the start_date and end_date.
  #
  # @return [Boolean] true if the content is active, false otherwise.
  #
  # @example
  #   content = SiteContent.new(start_date: DateTime.current - 1.day, end_date: DateTime.current + 1.day)
  #   content.active? # => true
  def active?
    return false if start_date.nil? || end_date.nil?
    return false if content.blank?

    now = DateTime.current
    start_date <= now && end_date >= now
  end
end
