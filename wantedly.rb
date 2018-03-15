require "capybara"
require "capybara/dsl"
require "capybara/poltergeist"

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

include Capybara::DSL # 警告が出るが動く

page.driver.headers = { "User-Agent" => "Mac Safari" }

visit('/user/sign_in')

fill_in "user[email]", :with => ARGV[0], match: :first # 同様のname属性を持つタグが他にあるため、この場合最初にマッチするものを探す
fill_in "user[password]", :with => ARGV[1]
# 引数にメールアドレスとパスワード

page.all(".wt-ui-button-blue")[0].trigger("click")
puts "Successfully logged in"

page.find(".label", :text => "スカウト").trigger("click")

page.find("span", :text => "条件で探す").trigger("click")
# page.find(".toggle-filter-panel").trigger("click") # 上でもよいが一応

page.find("#search_occupation_types_ option", :text => "エンジニア").trigger("click")
page.find("#search_activity option", :text => "1週間以内にログイン").trigger("click")
page.find("#search_locations", :text => "関東").trigger("click")
page.find("#search_motivation option", :text => "転職意欲が高い").trigger("click")

sleep(10) # 数秒待たないとユーザ情報の取得に失敗する
puts page.find("body")["outerHTML"] # htmlタグ出力で確認
puts current_url # 少し間違えるとURLにパラメータが含まれずうまくいかないことがあるのでURL目視確認
