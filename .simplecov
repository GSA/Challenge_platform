if ENV['CIRCLECI']
  SimpleCov.at_exit do
    result_hash = SimpleCov.result.to_hash

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
  add_filter '/vendor/'
  add_filter '/.bundler/'
  merge_timeout 1800
end
