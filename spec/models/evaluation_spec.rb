# == Schema Information
#
# Table name: evaluations
#
#  id                                 :bigint           not null, primary key
#  user_id                            :bigint           not null
#  evaluation_form_id                 :bigint           not null
#  submission_id                      :bigint           not null
#  evaluator_submission_assignment_id :bigint           not null
#  additional_comments                :text
#  revision_comments                  :text
#  total_score                        :decimal(10, 2)
#  completed_at                       :datetime
#  created_at                         :datetime         not null
#  updated_at                         :datetime         not null
#
require 'rails_helper'

RSpec.describe Evaluation, type: :model do
  let(:user) { create(:user, :evaluator) }
  let(:submission) { create(:submission) }
  let(:evaluator_submission_assignment) { create(:evaluator_submission_assignment, evaluator: user) }
  let(:evaluation_form) { create(:evaluation_form) }
  let(:evaluation) { create(:evaluation, user:, evaluation_form:, submission:, evaluator_submission_assignment:) }

  describe "associations" do
    it "belongs to a user" do
      expect(evaluation.user).to eq(user)
    end

    it "belongs to an evaluation form" do
      expect(evaluation.evaluation_form).to eq(evaluation_form)
    end

    it "belongs to a submission" do
      expect(evaluation.submission).to eq(submission)
    end

    it "belongs to an evaluator_submission_assignment" do
      expect(evaluation.evaluator_submission_assignment).to eq(evaluator_submission_assignment)
    end

    it "user can only have one evaluation per submission and form" do
      # One already exists from above let statements
      expect(evaluation.user).to be_present
      # Try creating another with same user, evaluation_form, and submission
      expect do
        create(:evaluation, user:, evaluation_form:, submission:)
      end.to raise_error(ActiveRecord::RecordInvalid,
                         "Validation failed: User #{I18n.t('evaluations.unique_user_for_evaluation_form_and_submission_error')}")
    end

    it "user can only have one evaluation per evaluator_submission_assignment" do
      # One already exists from above let statements
      expect(evaluation.user).to be_present
      # Try creating another with same user, evaluation_form, and submission
      expect do
        create(:evaluation, evaluator_submission_assignment:)
      end.to raise_error(ActiveRecord::RecordInvalid,
                         "Validation failed: Evaluator submission assignment #{I18n.t('evaluations.unique_evaluator_submission_assignment')}")
    end
  end

  describe "validations" do
    it "must have a user with a valid evaluator role" do
      user_with_invalid_role = create(:user, :admin)

      expect do
        create(:evaluation, evaluation_form: evaluation_form, user: user_with_invalid_role)
      end.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: User must have a valid evaluator role")

      user_with_valid_role = create(:user, :evaluator)
      evaluation = create(:evaluation, evaluation_form: evaluation_form, user: user_with_valid_role)

      expect(evaluation).to be_valid
    end

    it "is invalid if total_score < 0" do
      expect do
        evaluation.update!(total_score: -1)
      end.to raise_error(ActiveRecord::RecordInvalid,
                         "Validation failed: Total score must be greater than or equal to 0")
    end

    it "is valid if total_score > 0" do
      evaluation.update!(total_score: 1)
      expect(evaluation).to be_valid
    end

    it "is valid if additional_comments length is 3000 or less" do
      evaluation.update!(additional_comments: Faker::Lorem.characters(number: 3000))
      expect(evaluation).to be_valid
    end

    it "is invalid if additional_comments length is greater than 3000" do
      expect do
        evaluation.update!(additional_comments: Faker::Lorem.characters(number: 3001))
      end.to raise_error(ActiveRecord::RecordInvalid,
                         "Validation failed: Additional comments #{I18n.t('form.errors.too_long',
                                                                          field_name: 'Additional comments', max_length: 3000)}")
    end

    it "is valid if revision_comments length is 3000 or less" do
      evaluation.update!(revision_comments: Faker::Lorem.characters(number: 3000))
      expect(evaluation).to be_valid
    end

    it "is invalid if revision_comments length is greater than 3000" do
      expect do
        evaluation.update!(revision_comments: Faker::Lorem.characters(number: 3001))
      end.to raise_error(ActiveRecord::RecordInvalid,
                         "Validation failed: Revision comments #{I18n.t('form.errors.too_long',
                                                                        field_name: 'Revision comments', max_length: 3000)}")
    end
  end
end
