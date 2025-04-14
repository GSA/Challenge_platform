# spec/models/contact_form_spec.rb

require 'rails_helper'

RSpec.describe ContactForm do
  let(:valid_attributes) do
    {
      email: 'test@example.com',
      body: 'Test message',
      challenge_id: 1
    }
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      form = described_class.new(valid_attributes)
      expect(form).to be_valid
    end

    it 'is invalid without an email' do
      form = described_class.new(valid_attributes.merge(email: nil))
      expect(form).not_to be_valid
      expect(form.errors).to include('Email is invalid or missing')
    end

    it 'is invalid with an invalid email' do
      form = described_class.new(valid_attributes.merge(email: 'invalid'))
      expect(form).not_to be_valid
      expect(form.errors).to include('Email is invalid or missing')
    end

    it 'is invalid without a body' do
      form = described_class.new(valid_attributes.merge(body: nil))
      expect(form).not_to be_valid
      expect(form.errors).to include('Body must be at least 3 characters long')
    end

    it 'is invalid with a short body' do
      form = described_class.new(valid_attributes.merge(body: 'ab'))
      expect(form).not_to be_valid
      expect(form.errors).to include('Body must be at least 3 characters long')
    end
  end
end
