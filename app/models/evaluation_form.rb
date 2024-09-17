# frozen_string_literal: true

class EvaluationForm < ApplicationRecord
  belongs_to :challenge

  enum :status, { draft: 0, ready: 1, published: 2 }

  validates :title, presence: true
  validates :instructions, presence: true
  validates :challenge_phase, presence: true
end
