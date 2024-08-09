# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  attribute :inserted_at, :datetime, precision: 6
  attribute :updated_at, :datetime, precision: 6

  private_class_method
  # created_at timestamp is currently overridden to inserted_at due to shared Phoenix database
  def self.timestamp_attributes_for_create
    # only strings allowed here, symbols won't work, see below commit for more details
    # https://github.com/rails/rails/commit/2b5dacb43dd92e98e1fd240a80c2a540ed380257 
    super << 'inserted_at' 
  end
end
