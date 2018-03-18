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


def wait(selector)
  until has_css?(selector)
    sleep
  end
end

def condition(selector, text)
  page.find(selector, :text => text).trigger("click")
  wait(".bookmark-button")
end

page.driver.headers = { "User-Agent" => "Mac Safari" }

visit("/user/sign_in")

fill_in "user[email]", :with => ARGV[0], match: :first # 同様のname属性を持つタグが他にあるため、この場合最初にマッチするものを探す
fill_in "user[password]", :with => ARGV[1]

page.all(".wt-ui-button-blue")[0].trigger("click") # ログインボタン
puts "Successfully logged in"

page.find(".label", :text => "スカウト").trigger("click")
# パラメータつきでURLにvisitすると何故かトップに行くので使わない

condition(".toggle-filter-panel", "条件で探す")
wait(".open")

condition(".select-box li", "エンジニア")
condition(".select-box li", "1週間以内にログイン")
condition(".select-box li", "関東")
condition(".select-box li", "転職意欲が高い")
sleep(10) # wait(selector)はここでは意味を成さない ∵id, classは検索条件絞込前後で変化しない
page.save_screenshot('~/Downloads/screenshot.png')

page.all(".bookmark-button").each do |button|
  button["outerHTML"] # これだけだと最初の読み込みの10名しか表示されない
  # 条件で絞り込みできたらクリックさせる
end
