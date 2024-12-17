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
    current_criteria = evaluation_criteria.reject(&:marked_for_destruction?)

    titles = current_criteria.map(&:title)
    duplicate_titles = titles.select { |title| titles.count(title) > 1 }.uniq

    return if duplicate_titles.empty?

    duplicate_titles.each do |duplicate_title|
      current_criteria.each do |criterion|
        if criterion.title == duplicate_title
          criterion.errors.add(:title, I18n.t("evaluation_criteria.duplicate_title_error"))
        end
      end
    end

    errors.add(:base, I18n.t("evaluation_criterion_unique_title_in_form_error"))
  end

  def criteria_weights_must_sum_to_one_hundred
    current_criteria = evaluation_criteria.reject(&:marked_for_destruction?)

    total_weight = current_criteria.sum do |criteria|
      criteria.points_or_weight.to_i
    end

    return unless weighted_scoring? && total_weight != 100

    current_criteria.each_with_index do |criteria, _index|
      criteria.errors.add("points_or_weight", I18n.t("evaluation_criteria.must_sum_to_100_error"))
    end

    errors.add(:base, I18n.t("evaluation_form_criteria_weight_total_error"))
  end
end
