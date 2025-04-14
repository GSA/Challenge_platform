# spec/helpers/contact_form_helper_spec.rb

require 'rails_helper'

RSpec.describe ContactFormHelper, type: :helper do
  describe '#valid_contact_form?' do
    context 'with valid params' do
      before do
        allow(helper).to receive(:params).and_return({
          email: 'test@example.com',
          body: 'Test message'
        })
      end

      it 'returns true' do
        expect(helper.valid_contact_form?).to be true
      end
    end

    context 'with invalid params' do
      before do
        allow(helper).to receive(:params).and_return({
          email: 'invalid',
          body: ''
        })
      end

      it 'returns false' do
        expect(helper.valid_contact_form?).to be false
      end

      it 'collects error messages' do
        expect(helper.contact_form_errors).to eq({
          email: ["Please enter a valid email address"],
          body: ["Your question or comment must be greater than 2 characters"]
        })
      end
    end
  end
end
