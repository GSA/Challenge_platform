# frozen_string_literal: true

# == Schema Information
#
# Table name: submission_documents
#
#  id            :bigint           not null, primary key
#  user_id       :bigint           not null
#  submission_id :bigint
#  filename      :string(255)      not null
#  key           :uuid             not null
#  extension     :string(255)      not null
#  name          :string(255)
#  inserted_at   :datetime         not null
#  updated_at    :datetime         not null
#
class Document < ApplicationRecord
  self.table_name = 'submission_documents'

  belongs_to :user
  belongs_to :submission

  def external_url
    if Rails.env.production? || Rails.env.staging?
      s3_link
    else
      file_system_link
    end
  end

  def file_system_link
    "#{ENV.fetch('PHOENIX_URI')}/uploads/documents/#{key}#{extension}"
  end

  def key_url
    "documents/#{key}#{extension}"
  end

  def s3_link
    s3 = Fog::Storage.new(provider: 'AWS', region: ENV.fetch('AWS_REGION'),
                          aws_access_key_id: ENV.fetch('AWS_ACCESS_KEY_ID'),
                          aws_secret_access_key: ENV.fetch('AWS_SECRET_ACCESS_KEY'))
    directory = s3.directories.new(key: ENV.fetch('AWS_BUCKET_NAME'))
    directory.files.new(key: key_url).url(Time.zone.now + 60) # link good for 60 seconds
  end

  def display_name
    "#{name} (#{extension})"
  end
end
