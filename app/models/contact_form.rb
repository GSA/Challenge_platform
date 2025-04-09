# frozen_string_literal: true

class ContactForm
  attr_accessor :email, :body, :challenge_id

  def initialize(attributes = {})
    @email = attributes[:email]
    @body = attributes[:body]
    @challenge_id = attributes[:challenge_id]
  end

  def valid?
    validate_email && validate_body && validate_challenge_id
  end

  def errors
    @errors ||= []
  end

  private

  def validate_email
    if email.present? && email =~ URI::MailTo::EMAIL_REGEXP
      true
    else
      errors << "Email is invalid or missing"
      false
    end
  end

  def validate_body
    if body.present? && body.length >= 3
      true
    else
      errors << "Body must be at least 3 characters long"
      false
    end
  end

  def validate_challenge_id
    if challenge_id.present?
      true
    else
      errors << "Challenge ID is missing"
      false
    end
  end
end
