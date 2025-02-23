# frozen_string_literal: true

# The main app mailer for sending emails.
# The app does not process inbound messages.
class ApplicationMailer < ActionMailer::Base
  default from: "support@challenge.gov"
  layout "mailer"
end
