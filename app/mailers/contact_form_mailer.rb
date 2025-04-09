# app/mailers/contact_form_mailer.rb

class ContactFormMailer < ApplicationMailer
  def contact(challenge, from_email, body)
    @challenge = challenge
    @from_email = from_email
    @body = body
    attach_logo
    mail(
      to: @challenge.poc_email,
      subject: "Message from Public Visitor: #{@challenge.title}",
      reply_to: @from_email
    )
  end

  def contact_confirmation(to_email, challenge, body)
    @challenge = challenge
    @body = body
    attach_logo
    mail(
      to: to_email,
      subject: "Challenge.gov - Challenge #{@challenge.title}: Contact Confirmation"
    )
  end

  private

  def attach_logo
    logo_path = Rails.public_path.join('platform-assets/images/challenge_gov_logo.png')
    attachments.inline['challenge_gov_logo.png'] = File.read(logo_path)
  end
end
