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
