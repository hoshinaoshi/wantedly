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

def condition(selector, text)
    page.find(selector, :text => text).trigger("click")
  sleep(10) # 待たないとユーザ情報の取得に失敗する
end

page.driver.headers = { "User-Agent" => "Mac Safari" }

visit("/user/sign_in")

fill_in "user[email]", :with => ARGV[0], match: :first # 同様のname属性を持つタグが他にあるため、この場合最初にマッチするものを探す
fill_in "user[password]", :with => ARGV[1]
# 引数にメールアドレスとパスワード

page.all(".wt-ui-button-blue")[0].trigger("click") # ログインボタン
puts "Successfully logged in"

page.find(".label", :text => "スカウト").trigger("click")
# パラメータつきでURLにvisitすると何故かトップに行くので使わない

condition("span", "条件で探す")
# page.find(".toggle-filter-panel").trigger("click") # 上でもよいが一応

condition("#search_occupation_types_ option", "エンジニア")
condition("#search_activity option", "1週間以内にログイン")
condition("#search_locations option", "関東")
condition("#search_motivation option", "転職意欲が高い")

puts page.find("body")["outerHTML"] # htmlタグ出力で確認
puts current_url # 少し間違えるとURLにパラメータが含まれずうまくいかないことがあるのでURL目視確認

page.all(".bookmark-button").each do |button|
  p button["outerHTML"] # これだけだと最初の読み込みの10名しか表示されない
  # 条件で絞り込みできたらクリックさせる
end
