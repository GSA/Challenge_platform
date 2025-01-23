# frozen_string_literal: true

class Document < ApplicationRecord
  self.table_name = 'submission_documents'

  belongs_to :user
  belongs_to :submission

  def external_url
    "#{ENV.fetch("PHOENIX_URI")}/uploads/documents/#{key}#{extension}"
  end

  def display_name
    "#{name} (#{extension})"
  end
end
