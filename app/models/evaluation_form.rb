# frozen_string_literal: true

class EvaluationForm < ApplicationRecord
  belongs_to :challenge

  validates :challenge_phase, presence: true
end
