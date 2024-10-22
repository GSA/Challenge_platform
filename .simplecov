puts '.simplecov config init'
require 'simplecov_json_formatter'
SimpleCov.formatter = SimpleCov::Formatter::JSONFormatter

if ENV['CIRCLECI']

  SimpleCov.at_exit do
    result_hash = SimpleCov.result.to_hash
    puts "result_hash=#{result_hash.keys.inspect}"

    if result_hash.keys == ['Cucumber, RSpec']
      if SimpleCov.result.covered_percent < 100
        puts "=========== Lines missing coverage: ==========="
        result_hash['Cucumber, RSpec']['coverage'].each do |file_name, file_lines|
          file_lines.each_with_index { |val, index| puts "#{file_name}, #{index + 1}" if val == 0 }
        end
      end
    end
  end
end

SimpleCov.start 'rails' do
  puts "SimpleCov formatter=#{self.formatter}"
  puts "CC_TEST_REPORTER_ID=#{ENV["CC_TEST_REPORTER_ID"]}"

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

  add_filter '/app/controllers/sandbox_controller.rb'

  merge_timeout 1800
end
