Capybara.default_max_wait_time = 5
Capybara.predicates_wait = true
Capybara.register_driver :selenium_chrome_headless do |app|
  # store any downloads in a temp directory
  options = Selenium::WebDriver::Chrome::Options.new(
    prefs: {
    'download.prompt_for_download' => false,
    'download.default_directory' => '/tmp/chromedriver-downloads'
  })
  options.add_argument('--headless')
  options.add_argument('--enable-automation')
  options.add_argument('--test-type')
  options.add_argument('--disable-gpu')
  options.add_argument('--no-sandbox')
  options.add_argument('--disable-dev-shm-usage')
  options.add_argument('--window-size=1400,1400')
  Capybara::Selenium::Driver.new(app, browser: :chrome, options:)
end

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :rack_test
    WebMock.allow_net_connect!
  end

  config.before(:each, :js, type: :system) do
    driven_by :selenium_chrome_headless

    # Uncomment the next line to run system tests locally in a visible (non-headless) browser
    # driven_by :selenium, using: :chrome, screen_size: [1400, 1400]
  end

  config.after(:each, type: :system) do
    WebMock.disable_net_connect!(allow_localhost: true)
  end
end
