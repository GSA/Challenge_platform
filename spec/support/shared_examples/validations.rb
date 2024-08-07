# spec/support/shared_examples/validations.rb
RSpec.shared_examples 'a model with required attributes' do |attributes|
  attributes.each do |attribute|
    it "validates presence of #{attribute}" do
      model = described_class.new(attribute => nil)
      expect(model).not_to be_valid
      expect(model.errors[attribute]).to include("can't be blank")
    end
  end
end
