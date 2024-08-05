# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  before_save :set_updated_at
  before_create :set_inserted_at

  self.record_timestamps = false

  attribute :inserted_at, :datetime, precision: 6
  attribute :updated_at, :datetime, precision: 6

  private

  def set_inserted_at
    self.inserted_at ||= Time.current
  end

  def set_updated_at
    self.updated_at ||= Time.current
  end
end
