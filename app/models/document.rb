class Document < ApplicationRecord
  self.table_name = 'submission_documents'

  belongs_to :user
  belongs_to :submission

  def external_url
    ENV.fetch("PHOENIX_URI") +
    "/uploads/documents/" +
    self.key +
    self.extension
  end

  def display_name
    "#{self.name} (#{self.extension})"
  end  
end
