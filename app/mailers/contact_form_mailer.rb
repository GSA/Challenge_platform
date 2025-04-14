# frozen_string_literal: true

# Mailer for the contact form
class ContactFormMailer < ApplicationMailer
  def contact(challenge, from_email, body)
    @challenge = challenge
    @from_email = from_email
    @body = body
    attach_logo
    mail(
      to: @challenge.poc_email,
      subject: t('mailers.contact_form.subject', challenge_title: @challenge.title),
      reply_to: @from_email
    )
  end

  def contact_confirmation(to_email, challenge, body)
    @challenge = challenge
    @body = body
    attach_logo
    mail(
      to: to_email,
      subject: t('mailers.contact_form.confirmation_subject', challenge_title: @challenge.title)
    )
  end

  private

  def attach_logo
    logo_path = Rails.public_path.join('platform-assets/images/challenge_gov_logo.png')
    attachments.inline['challenge_gov_logo.png'] = File.read(logo_path)
  end
end
