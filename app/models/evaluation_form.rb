# frozen_string_literal: true

class EvaluationForm < ApplicationRecord
  belongs_to :challenge, required: false

end
