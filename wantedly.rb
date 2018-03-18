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
  find(selector, :text => text).trigger("click")
  wait(".bookmark-button")
end

page.driver.headers = { "User-Agent" => "Mac Safari" }
page.driver.resize_window(1500, 1000)

visit("/user/sign_in")

fill_in "user[email]", :with => ARGV[0], match: :first # 同様のname属性を持つタグが他にあるため、この場合最初にマッチするものを探す
fill_in "user[password]", :with => ARGV[1]

all(".wt-ui-button-blue")[0].trigger("click") # ログインボタン
puts "Successfully logged in"

find(".label", :text => "スカウト").trigger("click")
# パラメータつきでURLにvisitすると何故かトップに行くので使わない

condition(".toggle-filter-panel", "条件で探す")

conditions = %w(エンジニア 1週間以内にログイン 関東 転職意欲が高い)

conditions.each do |cond|
  condition(".select-box li", cond)
end
puts "accepted the condition"

fill_in "input#search_age_range", :with => "18-35"
# puts find("input#search_age_range").value
# puts find("search[age_range]").value
sleep(10) # wait(selector)はここでは意味を成さない ∵id, classは検索条件絞込前後で変化しない
save_screenshot('~/Downloads/screenshot.png')

# puts all("ul.user-activities .user-activity span")[1].gsub("歳", "").to_i

# if all("ul.user-activities .user-activity span")[1].gsub("歳", "").to_i <= 35
#   all(".bookmark-button").each do |button|
#     puts "YESSSSSSSS"
#     # button # これだけだと最初の読み込みの10名しか表示されない
#     # 条件で絞り込みできたらクリックさせる
#   end
# else
#   puts "NOOOO"
# end
