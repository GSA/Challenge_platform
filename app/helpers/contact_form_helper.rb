# frozen_string_literal: true

# Helper methods for the challenge contact form
module ContactFormHelper
  def valid_contact_form?
    return false unless params[:email].present? && params[:body].present?
    email_valid? && body_valid?
  end

  def contact_form_errors
    {
      email: email_errors,
      body: body_errors
    }
  end

  private

  def email_valid?
    params[:email].present? && params[:email] =~ URI::MailTo::EMAIL_REGEXP
  end

  def body_valid?
    params[:body].present? && params[:body].length > 2
  end

  def email_errors
    email_valid? ? [] : ["Please enter a valid email address"]
  end

  def body_errors
    body_valid? ? [] : ["Your question or comment must be greater than 2 characters"]
  end
end
