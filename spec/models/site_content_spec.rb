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
  pending "add some examples to (or delete) #{__FILE__}"
end
