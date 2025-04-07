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
end
