# frozen_string_literal: true

# Helper methods for the challenge contact form
module ContactFormHelper
  def contact_form
    @challenge = Challenge.find(params[:id])

    if valid_contact_form?
      render json: { success: true }, status: :ok
    else
      render json: { email: email_errors, body: body_errors }, status: :unprocessable_entity
    end
  end

  private

  def valid_contact_form?
    email_valid? && body_valid?
  end

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
