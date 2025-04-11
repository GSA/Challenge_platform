# frozen_string_literal: true

# Preview for the contact form mailer
# http://localhost:3000/rails/mailers
class ContactFormMailerPreview < ActionMailer::Preview
  def contact
    challenge = find_or_create_challenge
    ContactFormMailer.contact(challenge, 'visitor@example.com', 'This is a test message for the contact email.')
  end

  def contact_confirmation
    challenge = find_or_create_challenge
    to_email = 'visitor@example.com'
    body = 'This is a test message for the confirmation email.'
    ContactFormMailer.contact_confirmation(to_email, challenge, body)
  end

  private

  def find_or_create_challenge
    Challenge.find_by(title: 'Test Challenge') || Challenge.create!(
      title: 'Test Challenge',
      description: 'This is a test challenge for email previews.',
      user: find_or_create_user,
      agency: find_or_create_agency,
      poc_email: 'challenge_manager@example.gov',
      status: 'published',
      prize_total: 10_000_000
    )
  end

  def find_or_create_user
    User.find_by(email: 'test_user@example.gov') || User.create!(
      email: 'test_user@example.gov',
      first_name: 'Test',
      last_name: 'User',
      role: 'challenge_manager'
    )
  end

  def find_or_create_agency
    Agency.find_by(name: 'Test Agency') || Agency.create!(
      name: 'Test Agency',
      acronym: 'TA'
    )
  end
end
