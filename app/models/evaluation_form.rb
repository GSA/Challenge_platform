# frozen_string_literal: true

# == Schema Information
#
# Table name: evaluation_forms
#
#  id                :bigint           not null, primary key
#  title             :string           not null
#  instructions      :string           not null
#  comments_required :boolean          default(FALSE)
#  weighted_scoring  :boolean          default(FALSE)
#  closing_date      :date             not null
#  challenge_id      :bigint           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  phase_id          :bigint           not null
#
class EvaluationForm < ApplicationRecord
  belongs_to :challenge
  belongs_to :phase
  has_many :evaluation_criteria, lambda {
    order(:created_at)
  }, class_name: 'EvaluationCriterion', dependent: :destroy, inverse_of: :evaluation_form
  accepts_nested_attributes_for :evaluation_criteria, allow_destroy: true

  scope :by_user, lambda { |user|
    joins(challenge: :challenge_manager_users).
      where(challenge_manager_users: { id: user.id })
  }

  validates :title, presence: true, length: { maximum: 150 }
  validates :instructions, presence: true
  validates :closing_date, presence: true

  validates :phase_id, uniqueness: true

  validate :criteria_weights_must_sum_to_one_hundred
  validate :validate_unique_criteria_titles

  private

  def validate_unique_criteria_titles
    titles = evaluation_criteria.reject(&:marked_for_destruction?).map(&:title)

    return unless titles.uniq.length != titles.length

    errors.add(:base, I18n.t("evaluation_criterion_unique_title_in_form_error"))
  end

  def criteria_weights_must_sum_to_one_hundred
    total_weight = evaluation_criteria.reject(&:marked_for_destruction?).sum do |criteria|
      criteria.points_or_weight.to_i
    end

    return unless weighted_scoring? && total_weight != 100

    errors.add(:base, I18n.t("evaluation_form_criteria_weight_total_error"))
  end
end
