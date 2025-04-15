# frozen_string_literal: true

# Service for sending contact form emails
class ContactFormsService
  def self.send_email(challenge, params)
    contact_form = ContactForm.new(
      email: params[:email],
      body: params[:body],
      challenge_id: challenge.id
    )

    if contact_form.valid?
      ContactFormMailer.contact(challenge, params[:email], params[:body]).deliver_later
      ContactFormMailer.contact_confirmation(params[:email], challenge, params[:body]).deliver_later
      { success: true }
    else
      { success: false, errors: contact_form.errors }
    end
  end
end
