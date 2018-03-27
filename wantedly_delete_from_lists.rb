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

include Capybara::DSL # 警告が出るが動く

page.driver.headers = { "User-Agent": "Mac Safari" }

visit("/user/sign_in")

fill_in "user[email]", with: ARGV[0], match: :first # 同様のname属性を持つタグが他にあるため、この場合最初にマッチするものを探す
fill_in "user[password]", with: ARGV[1]

all(".wt-ui-button-blue")[0].trigger("click") # ログインボタン
puts "Successfully logged in"
find(".label", text: "スカウト").trigger("click") # パラメータつきでURLにvisitすると何故かトップに行くので使わない
find(".scout-bookmarked-users-button").trigger("click")
sleep(3)

waitings = all(".content-title-count")[0].text.to_i # お気に入り人数
pages = waitings.div(10) + 1 # 1ページ(ロード)あたりスカウト待ち10人 ∴スカウト待ち人数を10で割った商+1 がリロード回数

pages.times do
  for num in 0..9 do # 一回のロードにつき10名
    within(all("article.user-profile")[num]) do
      find(".bookmark-button").trigger("click")
      puts "Unbookmarked"
    end
    sleep(rand(3))
  end
  visit current_url
end
