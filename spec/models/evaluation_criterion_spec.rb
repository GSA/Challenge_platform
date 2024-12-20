# == Schema Information
#
# Table name: evaluation_criteria
#
#  id                 :bigint           not null, primary key
#  evaluation_form_id :bigint           not null
#  title              :string           not null
#  description        :string           not null
#  points_or_weight   :integer          not null
#  scoring_type       :integer          not null
#  option_range_start :integer
#  option_range_end   :integer
#  option_labels      :json
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
require 'rails_helper'

RSpec.describe EvaluationCriterion, type: :model do
  let(:challenge) { create(:challenge) }
  let(:phase) { create(:phase, challenge:) }
  let(:evaluation_form) { create(:evaluation_form, challenge:, phase:, scale_type: "point") }
  let(:evaluation_criterion) { create(:evaluation_criterion, evaluation_form:) }

  describe "creating an evaluation criterion" do
    it "belongs to an evaluation form" do
      expect(evaluation_criterion.evaluation_form).to eq(evaluation_form)
    end

    it "validates presence of title" do
      evaluation_criterion.title = nil
      expect(evaluation_criterion).not_to be_valid
      expect(evaluation_criterion.errors[:title]).to include("can't be blank")
    end

    it "validates presence of description" do
      evaluation_criterion.description = nil
      expect(evaluation_criterion).not_to be_valid
      expect(evaluation_criterion.errors[:description]).to include("can't be blank")
    end

    it "validates presence of points or weight" do
      evaluation_criterion.points_or_weight = nil
      expect(evaluation_criterion).not_to be_valid
      expect(evaluation_criterion.errors[:points_or_weight]).to include("can't be blank")
    end
  end

  describe "updating an evaluation criterion" do
    it "successfully updates valid attributes" do
      evaluation_criterion.update(title: "Updated Title")
      expect(evaluation_criterion.reload.title).to eq("Updated Title")
    end

    it "does not update invalid attributes" do
      evaluation_criterion.update(title: nil)
      expect(evaluation_criterion.errors[:title]).to include("can't be blank")
    end
  end

  describe "destroying an evaluation criterion" do
    it "successfully destroys the criterion" do
      evaluation_criterion_id = evaluation_criterion.id
      evaluation_criterion.destroy
      expect { described_class.find(evaluation_criterion_id) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
