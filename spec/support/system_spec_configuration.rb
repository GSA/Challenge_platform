Capybara.default_max_wait_time = 150
Capybara.predicates_wait = true
Capybara.disable_animation = true
Capybara.register_driver :selenium_chrome_headless do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--headless')
  options.add_argument('--disable-gpu')
  options.add_argument('--no-sandbox')
  options.add_argument('--disable-dev-shm-usage')
  options.add_argument('--window-size=1400,1400')
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :rack_test
    WebMock.allow_net_connect!
  end

  config.before(:each, :js, type: :system) do
    # driven_by :selenium_chrome_headless

    # Uncomment the next line to run system tests locally in a visible (non-headless) browser
    driven_by :selenium, using: :chrome, screen_size: [1400, 1400]
  end

  config.after(:each, type: :system) do
    WebMock.disable_net_connect!(allow_localhost: true)
  end
end
