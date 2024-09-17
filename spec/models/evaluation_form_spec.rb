require 'rails_helper'

RSpec.describe EvaluationForm, type: :model do
  describe 'validations' do
    it 'validates presence of title' do
      evaluation_form = described_class.new(title: nil)
      expect(evaluation_form).not_to be_valid
      expect(evaluation_form.errors[:title]).to include("can't be blank")
    end

    it 'validates presence of instructions' do
      evaluation_form = described_class.new(instructions: nil)
      expect(evaluation_form).not_to be_valid
      expect(evaluation_form.errors[:instructions]).to include("can't be blank")
    end
  end

  describe 'default values' do
    it 'sets status to draft by default' do
      evaluation_form = described_class.new
      expect(evaluation_form.status).to eq('draft')
    end
  end
end
