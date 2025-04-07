# == Schema Information
#
# Table name: evaluation_scores
#
#  id                      :bigint           not null, primary key
#  evaluation_id           :bigint           not null
#  evaluation_criterion_id :bigint           not null
#  score                   :integer
#  score_override          :integer
#  comment                 :text
#  comment_override        :text
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#
require 'rails_helper'

RSpec.describe EvaluationScore, type: :model do
  let(:evaluation_form) { create(:evaluation_form) }
  let(:evaluation) { create(:evaluation, evaluation_form:) }
  let(:evaluation_score) { create(:evaluation_score, evaluation:) }

  describe "associations" do
    it "belongs to an evaluation" do
      expect(evaluation_score.evaluation).to eq(evaluation)
    end

    # TODO: Possibly update this to check specific criterion
    # Would require some factory rework
    it "belongs to an evaluation criterion" do
      evaluation_score = create(:evaluation_score)
      expect(evaluation_score.evaluation_criterion).to be_present
    end

    it "there can only be one score per evaluation for a specific criterion" do
      # One already exists from above let statements
      expect(evaluation_score.evaluation_criterion).to be_present
      # Try creating another with the same evaluation and a criteria that already has a score from factory
      expect do
        create(:evaluation_score, evaluation:, evaluation_criterion: evaluation_form.evaluation_criteria[0])
      end.to raise_error(ActiveRecord::RecordInvalid,
                         "Validation failed: Evaluation #{I18n.t('evaluation_scores.unique_evaluation_for_evaluation_criterion_error')}")
    end
  end

  describe "score validations for numeric criterion" do
    it "is valid if score is equal to or less than criterion points_or_weight" do
      # TODO: Add calculated score checks and helper?
      evaluation_criterion = create(:evaluation_criterion, :numeric)
      points_or_weight = evaluation_criterion.points_or_weight
      evaluation_score = create(:evaluation_score, evaluation_criterion:)

      # Initially valid in factory with random valid score
      expect(evaluation_score).to be_valid
      expect(evaluation_score.effective_score).to eq(evaluation_score.score)

      # Update to verify
      new_score = rand(0..points_or_weight)
      evaluation_score.update!(score: new_score)
      expect(evaluation_score).to be_valid
      expect(evaluation_score.effective_score).to eq(evaluation_score.score)
      expect(evaluation_score.effective_score).to eq(new_score)

      # Verify override and effective score
      new_score = rand(0..points_or_weight)
      evaluation_score.update!(score_override: new_score)
      expect(evaluation_score).to be_valid
      expect(evaluation_score.effective_score).to eq(evaluation_score.score_override)
      expect(evaluation_score.effective_score).to eq(new_score)
    end

    it "is invalid if score is negative" do
      evaluation_criterion = create(:evaluation_criterion, :numeric)
      points_or_weight = evaluation_criterion.points_or_weight
      evaluation_score = create(:evaluation_score, evaluation_criterion:)

      expect do
        evaluation_score.update!(score: - 1)
      end.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Score must be greater than or equal to 0")

      # Clear validation error
      new_score = rand(0..points_or_weight)
      evaluation_score.update!(score: new_score)

      expect do
        evaluation_score.update!(score_override: - 1)
      end.to raise_error(ActiveRecord::RecordInvalid,
                         "Validation failed: Score override must be greater than or equal to 0")
    end

    it "is invalid if score is greater than criterion points_or_weight" do
      evaluation_criterion = create(:evaluation_criterion, :numeric)
      points_or_weight = evaluation_criterion.points_or_weight
      evaluation_score = create(:evaluation_score, evaluation_criterion:)

      expect do
        evaluation_score.update!(score: points_or_weight + 1)
      end.to raise_error(ActiveRecord::RecordInvalid,
                         "Validation failed: Score #{I18n.t('form.errors.over_max', field_name: 'Score',
                                                                                    max: points_or_weight)}")

      # Clear validation error
      new_score = rand(0..points_or_weight)
      evaluation_score.update!(score: new_score)

      expect do
        evaluation_score.update!(score_override: points_or_weight + 1)
      end.to raise_error(ActiveRecord::RecordInvalid,
                         "Validation failed: Score override #{I18n.t('form.errors.over_max', field_name: 'Score',
                                                                                             max: points_or_weight)}")
    end
  end

  describe "score validations for rating criterion" do
    it "is valid if score is equal to or less than criterion points_or_weight" do
      evaluation_criterion = create(:evaluation_criterion, :rating)
      option_range_start = evaluation_criterion.option_range_start
      option_range_end = evaluation_criterion.option_range_end
      evaluation_score = create(:evaluation_score, evaluation_criterion:)

      # Initially valid in factory with random valid score
      expect(evaluation_score).to be_valid
      expect(evaluation_score.effective_score).to eq(evaluation_score.score)

      # Update to verify
      new_score = rand(option_range_start..option_range_end)
      evaluation_score.update!(score: new_score)
      expect(evaluation_score).to be_valid
      expect(evaluation_score.effective_score).to eq(evaluation_score.score)
      expect(evaluation_score.effective_score).to eq(new_score)

      # Verify override and effective score
      new_score = rand(option_range_start..option_range_end)
      evaluation_score.update!(score_override: new_score)
      expect(evaluation_score).to be_valid
      expect(evaluation_score.effective_score).to eq(evaluation_score.score_override)
      expect(evaluation_score.effective_score).to eq(new_score)
    end

    it "is invalid if score is negative" do
      evaluation_criterion = create(:evaluation_criterion, :rating)
      option_range_start = evaluation_criterion.option_range_start
      option_range_end = evaluation_criterion.option_range_end
      evaluation_score = create(:evaluation_score, evaluation_criterion:)

      expect do
        evaluation_score.update!(score: - 1)
      end.to raise_error(ActiveRecord::RecordInvalid,
                         "Validation failed: Score must be greater than or equal to 0, Score must be within the range #{option_range_start} to #{option_range_end}")

      # Clear validation error
      new_score = rand(option_range_start..option_range_end)
      evaluation_score.update!(score: new_score)

      expect do
        evaluation_score.update!(score_override: - 1)
      end.to raise_error(ActiveRecord::RecordInvalid,
                         "Validation failed: Score override must be greater than or equal to 0, Score override must be within the range #{option_range_start} to #{option_range_end}")
    end

    it "is invalid if score is greater than criterion points_or_weight" do
      evaluation_criterion = create(:evaluation_criterion, :rating)
      option_range_start = evaluation_criterion.option_range_start
      option_range_end = evaluation_criterion.option_range_end
      evaluation_score = create(:evaluation_score, evaluation_criterion:)

      expect do
        evaluation_score.update!(score: option_range_end + 1)
      end.to raise_error(ActiveRecord::RecordInvalid,
                         "Validation failed: Score must be within the range #{option_range_start} to #{option_range_end}")

      # Clear validation error
      new_score = rand(option_range_start..option_range_end)
      evaluation_score.update!(score: new_score)

      expect do
        evaluation_score.update!(score_override: option_range_end + 1)
      end.to raise_error(ActiveRecord::RecordInvalid,
                         "Validation failed: Score override must be within the range #{option_range_start} to #{option_range_end}")
    end
  end

  describe "score validations for binary criterion" do
    it "is valid if score is equal to or less than criterion points_or_weight" do
      evaluation_criterion = create(:evaluation_criterion, :binary)
      option_range_start = evaluation_criterion.option_range_start
      option_range_end = evaluation_criterion.option_range_end
      evaluation_score = create(:evaluation_score, evaluation_criterion:)

      # Initially valid in factory with random valid score
      expect(evaluation_score).to be_valid
      expect(evaluation_score.effective_score).to eq(evaluation_score.score)

      # Update to verify
      new_score = rand(option_range_start..option_range_end)
      evaluation_score.update!(score: new_score)
      expect(evaluation_score).to be_valid
      expect(evaluation_score.effective_score).to eq(evaluation_score.score)
      expect(evaluation_score.effective_score).to eq(new_score)

      # Verify override and effective score
      new_score = rand(option_range_start..option_range_end)
      evaluation_score.update!(score_override: new_score)
      expect(evaluation_score).to be_valid
      expect(evaluation_score.effective_score).to eq(evaluation_score.score_override)
      expect(evaluation_score.effective_score).to eq(new_score)
    end

    it "is invalid if score is negative" do
      evaluation_criterion = create(:evaluation_criterion, :binary)
      option_range_start = evaluation_criterion.option_range_start
      option_range_end = evaluation_criterion.option_range_end
      evaluation_score = create(:evaluation_score, evaluation_criterion:)

      expect do
        evaluation_score.update!(score: - 1)
      end.to raise_error(ActiveRecord::RecordInvalid,
                         "Validation failed: Score must be greater than or equal to 0, Score must be within the range #{option_range_start} to #{option_range_end}")

      # Clear validation error
      new_score = rand(option_range_start..option_range_end)
      evaluation_score.update!(score: new_score)

      expect do
        evaluation_score.update!(score_override: - 1)
      end.to raise_error(ActiveRecord::RecordInvalid,
                         "Validation failed: Score override must be greater than or equal to 0, Score override must be within the range #{option_range_start} to #{option_range_end}")
    end

    it "is invalid if score is greater than criterion points_or_weight" do
      evaluation_criterion = create(:evaluation_criterion, :binary)
      option_range_start = evaluation_criterion.option_range_start
      option_range_end = evaluation_criterion.option_range_end
      evaluation_score = create(:evaluation_score, evaluation_criterion:)

      expect do
        evaluation_score.update!(score: option_range_end + 1)
      end.to raise_error(ActiveRecord::RecordInvalid,
                         "Validation failed: Score must be within the range #{option_range_start} to #{option_range_end}")

      # Clear validation error
      new_score = rand(option_range_start..option_range_end)
      evaluation_score.update!(score: new_score)

      expect do
        evaluation_score.update!(score_override: option_range_end + 1)
      end.to raise_error(ActiveRecord::RecordInvalid,
                         "Validation failed: Score override must be within the range #{option_range_start} to #{option_range_end}")
    end
  end

  describe "comment validation" do
    it "is valid if comment length is 3000 or less" do
      new_comment = Faker::Lorem.characters(number: 3000)
      evaluation_score.update!(comment: new_comment)
      expect(evaluation_score).to be_valid
      expect(evaluation_score.effective_comment).to eq(evaluation_score.comment)
      expect(evaluation_score.comment).to eq(new_comment)

      new_comment = Faker::Lorem.characters(number: 3000)
      evaluation_score.update!(comment_override: new_comment)
      expect(evaluation_score).to be_valid
      expect(evaluation_score.effective_comment).to eq(evaluation_score.comment_override)
      expect(evaluation_score.comment_override).to eq(new_comment)
    end

    it "is invalid if comments length is greater than 3000" do
      expect do
        evaluation_score.update!(comment: Faker::Lorem.characters(number: 3001))
      end.to raise_error(ActiveRecord::RecordInvalid,
                         "Validation failed: Comment #{I18n.t('form.errors.too_long', field_name: 'Comment',
                                                                                      max_length: 3000)}")

      evaluation_score.update!(comment: Faker::Lorem.characters(number: 3000))

      expect do
        evaluation_score.update!(comment_override: Faker::Lorem.characters(number: 3001))
      end.to raise_error(ActiveRecord::RecordInvalid,
                         "Validation failed: Comment override #{I18n.t('form.errors.too_long', field_name: 'Comment',
                                                                                               max_length: 3000)}")
    end
  end
end
