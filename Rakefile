# frozen_string_literal: true

# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative "config/application"

Rails.application.load_tasks

namespace :cf do
  desc "Only run on the first application instance"
  task on_first_instance: :environment do
    instance_index = begin
      JSON.parse(ENV.fetch("VCAP_APPLICATION", nil))["instance_index"]
    rescue
      nil
    end
    exit(0) unless instance_index.zero?
  end
end
