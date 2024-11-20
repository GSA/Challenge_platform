require 'rails_helper'

RSpec.describe Evaluation, type: :model do
  let(:user) { create(:user, :evaluator) }
  let(:evaluation_form) { create(:evaluation_form) }
  let(:evaluation) { create(:evaluation, user:, evaluation_form:) }

  describe "associations" do
    it "belongs to a user" do
      expect(evaluation.user).to eq(user)
    end

    it "belongs to an evaluation form" do
      expect(evaluation.evaluation_form).to eq(evaluation_form)
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
                         "Validation failed: Additional comments cannot exceed 3000 characters")
    end

    it "is valid if revision_comments length is 3000 or less" do
      evaluation.update!(revision_comments: Faker::Lorem.characters(number: 3000))
      expect(evaluation).to be_valid
    end

    it "is invalid if revision_comments length is greater than 3000" do
      expect do
        evaluation.update!(revision_comments: Faker::Lorem.characters(number: 3001))
      end.to raise_error(ActiveRecord::RecordInvalid,
                         "Validation failed: Revision comments cannot exceed 3000 characters")
    end

    # TODO: Possibly check uniqueness with user and evaluation_form?
  end

  describe "status" do
    it "allows updating and checking the status" do
      expect(evaluation).to be_not_started
      expect(evaluation.status).to eq("not_started")

      evaluation.recused!
      expect(evaluation).to be_recused
      expect(evaluation.status).to eq("recused")

      evaluation.not_started!
      expect(evaluation).to be_not_started
      expect(evaluation.status).to eq("not_started")

      evaluation.in_progress!
      expect(evaluation).to be_in_progress
      expect(evaluation.status).to eq("in_progress")

      evaluation.completed!
      expect(evaluation).to be_completed
      expect(evaluation.status).to eq("completed")
    end
  end
end
