# frozen_string_literal: true

class EvaluationForm < ApplicationRecord
  belongs_to :challenge


  validates :title, presence: true
  validates :instructions, presence: true
  validates :challenge_phase, presence: true
end
