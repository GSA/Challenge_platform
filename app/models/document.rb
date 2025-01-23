# frozen_string_literal: true

# == Schema Information
#
# Table name: submission_documents
#
#  id                 :bigint           not null, primary key
#  user_id            :bigint           not null
#  submission_id      :bigint
#  filename           :string(255)      not null
#  uuid               :uuid             not null
#  extension          :string(255)      not null
#  name               :string(255)
#  inserted_at        :datetime         not null
#  updated_at         :datetime         not null
#
class Document < ApplicationRecord
  self.table_name = 'submission_documents'

  belongs_to :user
  belongs_to :submission

  def external_url
    "#{ENV.fetch('PHOENIX_URI')}/uploads/documents/#{key}#{extension}"
  end

  def display_name
    "#{name} (#{extension})"
  end
end
