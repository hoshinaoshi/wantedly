module CapybaraConfig
  require "capybara"
  require "capybara/dsl"
  require "capybara/poltergeist"
  require "csv"
  require "pry"

  Capybara.current_driver = :poltergeist

  Capybara.configure do |config|
    config.run_server = false
    config.javascript_driver = :poltergeist
    config.app_host = "https://www.wantedly.com"
    config.default_max_wait_time = 10
    config.ignore_hidden_elements = false
  end

  Capybara.register_driver :poltergeist do |app|
    Capybara::Poltergeist::Driver.new(app, {timeout: 120, js: true, js_errors: false})
  end
end
