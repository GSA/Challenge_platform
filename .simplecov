SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new(
  [SimpleCov::Formatter::HTMLFormatter, SimpleCov::Formatter::JSONFormatter]
)

SimpleCov.start :rails do
  add_filter '/vendor/'
  add_filter '/.bundler/'
  add_filter '/.nix-bundler/'

  # Exclude ActionCable base files if not customized
  add_filter '/app/channels/application_cable/channel.rb'
  add_filter '/app/channels/application_cable/connection.rb'

  # Optionally exclude base classes if they don't have much custom logic
  # add_filter '/app/controllers/application_controller.rb'
  add_filter '/app/helpers/application_helper.rb'
  add_filter '/app/jobs/application_job.rb'
  add_filter '/app/mailers/application_mailer.rb'
  add_filter '/app/models/application_record.rb'
  add_filter '/app/controllers/pages_controller.rb'

  add_filter '/app/controllers/sandbox_controller.rb'

  merge_timeout 1800
end
