require 'capybara'
require 'capybara/dsl'
require 'capybara/poltergeist'
require 'nokogiri'
require 'open-uri'

Capybara.current_driver = :poltergeist

Capybara.configure do |config|
    config.run_server = false
    config.javascript_driver = :poltergeist
    config.app_host = "https://www.wantedly.com"
    config.default_max_wait_time = 60
    config.ignore_hidden_elements = false
end

Capybara.register_driver :poltergeist do |app|
    Capybara::Poltergeist::Driver.new(app, {:timeout=>120, :js=>true, :js_errors=>false})
end


module Crawler
  class Wantedly

    include Capybara::DSL

    def login(username, password)
      page.driver.headers = { "User-Agent" => "Mac Safari" }

      visit('/user/sign_in')

      fill_in "user[email]", :with => username, match: :first # 同様のname属性を持つタグが他にあるため、この場合最初にマッチするものを探す
      fill_in "user[password]", :with => password

      page.all(".wt-ui-button-blue")[0].trigger('click')

      find(".label", :text => "スカウト").trigger("click")
      find("span", :text => "条件で探す").trigger("click")

      # find(".select-box li", :text => "エンジニア").click
      # find(".select-box li", :text => "1週間以内にログイン").click
      # find(".select-box li", :text => "関東").click
      # find(".select-box li", :text => "転職意欲が高い").click

      # find(".select-box li", :text => "エンジニア").trigger("click")
      # find(".select-box li", :text => "1週間以内にログイン").trigger("click")
      # find(".select-box li", :text => "関東").trigger("click")
      # find(".select-box li", :text => "転職意欲が高い").trigger("click")

      find("#search_occupation_types_ option", :text => "エンジニア").trigger("click")
      find("#search_activity option", :text => "1週間以内にログイン").trigger("click")
      find("#search_locations", :text => "関東").trigger("click")
      find("#search_motivation option", :text => "転職意欲が高い").trigger("click")

      # find(".custom-select option", :text => "エンジニア").click
      # find(".custom-select option", :text => "1週間以内にログイン").click
      # find(".custom-select option", :text => "関東").click
      # find(".custom-select option", :text => "転職意欲が高い").click




      puts page.find("body")['outerHTML'] # htmlタグ出力
      puts current_url

    end
  end
end

crawler = Crawler::Wantedly.new
crawler.login(ARGV[0], ARGV[1])
