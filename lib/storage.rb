# frozen_string_literal: true

# Storage module for handling file storage and retrieval
# This module provides methods to generate URLs for files stored in different environments
# such as local file system or AWS S3.
#
# The `url` method generates a URL for the specified key based on the current Rails environment.
# In production and staging environments, it uses S3, while in development and test environments,
# it uses the local file system.
#
# The `file_system_url` method generates a URL for the local file system.
# The `s3_url` method generates a URL for AWS S3 with an optional expiration time.
# The `expires_in` option specifies how many seconds the generated URL should be valid.
module Storage
  def self.url(key, options = {})
    if Rails.env.production? || Rails.env.staging?
      s3_url(key, options)
    else
      file_system_url(key)
    end
  end

  def self.file_system_url(key)
    "#{Rails.configuration.phx_interop[:phx_uri]}/uploads/#{key}"
  end

  def self.s3_url(key, options = {})
    expires_at = Time.current + options.fetch(:expires_in, 1.hour)
    s3 = Fog::Storage.new(provider: 'AWS', region: ENV.fetch('AWS_REGION'),
                          aws_access_key_id: ENV.fetch('AWS_ACCESS_KEY_ID'),
                          aws_secret_access_key: ENV.fetch('AWS_SECRET_ACCESS_KEY'))
    directory = s3.directories.new(key: ENV.fetch('AWS_BUCKET_NAME'))
    directory.files.new(key:).url(expires_at)
  end
end