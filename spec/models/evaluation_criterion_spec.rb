require 'rails_helper'

RSpec.describe EvaluationCriterion, type: :model do
  let(:challenge) { create(:challenge) }
  let(:evaluation_form) { create(:evaluation_form, challenge:) }
  let(:evaluation_criterion) { create(:evaluation_criterion, evaluation_form:) }

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

  it "validates uniqueness of title within the same evaluation form" do
    create(:evaluation_criterion, evaluation_form:, title: "Unique Title")
    duplicate_criterion = build(:evaluation_criterion, evaluation_form:, title: "Unique Title")

    expect(duplicate_criterion).not_to be_valid
    expect(duplicate_criterion.errors[:title]).to include(I18n.t("evaluation_criterion_unique_title_in_form"))
  end
end
