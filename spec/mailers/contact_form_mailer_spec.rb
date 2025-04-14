# spec/mailers/contact_form_mailer_spec.rb

require 'rails_helper'

RSpec.describe ContactFormMailer, type: :mailer do
  let(:challenge) { create(:challenge, title: 'Test Challenge', poc_email: 'poc@example.com') }
  let(:from_email) { 'user@example.com' }
  let(:body) { 'Test message body' }

  describe '#contact' do
    let(:mail) { described_class.contact(challenge, from_email, body) }

    it 'renders the headers' do
      expect(mail.subject).to include(challenge.title)
      expect(mail.to).to eq([challenge.poc_email])
      expect(mail.reply_to).to eq([from_email])
    end

    it 'attaches the logo' do
      expect(mail.attachments.inline.first.filename).to eq('challenge_gov_logo.png')
    end
  end

  describe '#contact_confirmation' do
    let(:mail) { described_class.contact_confirmation(from_email, challenge, body) }

    it 'renders the headers' do
      expect(mail.subject).to include(challenge.title)
      expect(mail.to).to eq([from_email])
    end

    it 'attaches the logo' do
      expect(mail.attachments.inline.first.filename).to eq('challenge_gov_logo.png')
    end
  end
end
