require 'capybara'
require 'capybara/dsl'
require 'capybara/poltergeist'
require 'mechanize'

class Scrape
  #DSLのスコープを別けないと警告がでます
  include Capybara::DSL

  def initialize()
    Capybara.register_driver :poltergeist_debug do |app|
      Capybara::Poltergeist::Driver.new(app, :inspector => true)
    end

    Capybara.default_driver = :poltergeist
    Capybara.javascript_driver = :poltergeist
  end

  def visit_site
    page.driver.headers # => {}
    #ユーザエージェントの設定（必要に応じて）
    page.driver.headers = { "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/27.0.1453.116 Safari/537.36" }
    #リファラーの偽装（特に不要）
    #page.driver.add_headers("Referer" => "http://yahoo.co.jp")
    page.driver.headers
    visit('https://www.wantedly.com/enterprise/scouts#search%5Bkeywords%5D=&search%5Boccupation_types%5D%5B%5D=engineer&search%5Bactivity%5D=7&search%5Blocations%5D%5B%5D=kanto&search%5Bmotivation%5D=large&search%5Bscout_reply%5D=&search%5Bconnection%5D=&search%5Bscout_received%5D=&search%5Bage_range%5D=18-35&search%5Bgraduation_year%5D=&search%5Border%5D=recommend&search%5Bcountries%5D%5B%5D=japan&search%5Brecommended%5D=false&search%5Bbookmarked_users_params%5D=&filter_is_used=true')
    #スクリーンショットで保存
    page.save_screenshot('screenshot.png', :full => true)
    #within(:xpath, "//*[@id='toipcsfb']/div[1]/ul[1]") do
    #Nokogirオブジェクトの作成
    doc = Nokogiri::HTML.parse(page.html)
    puts doc
  end
end

agent = Mechanize.new
agent.user_agent = "Windows Mozilla"
agent.get('https://www.wantedly.com/user/sign_in') do |loginpage|
  response = loginpage.form_with(:dom_id => 'new_user') do |form|
    form.field_with(:name => 'user[email]').value = ARGV[0]
    form.field_with(:name => 'user[password]').value = ARGV[1]
  end.submit

scrape = Scrape.new
scrape.visit_site

end
