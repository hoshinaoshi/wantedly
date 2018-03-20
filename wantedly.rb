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
  Capybara::Poltergeist::Driver.new(app, {timeout: 120, js: true, js_errors: false})
end

include Capybara::DSL # 警告が出るが動く


def set_condition(selector, text)
  find(selector, text: text).trigger("click")
  sleep until has_css?(".bookmark-button") # こうしないと「ユーザ情報の取得に失敗しました」と出るため
end

page.driver.headers = { "User-Agent": "Mac Safari" }
page.driver.resize_window(1500, 1000) # スクショ用

visit("/user/sign_in")

fill_in "user[email]", with: ARGV[0], match: :first # 同様のname属性を持つタグが他にあるため、この場合最初にマッチするものを探す
fill_in "user[password]", with: ARGV[1]

all(".wt-ui-button-blue")[0].trigger("click") # ログインボタン
puts "Successfully logged in"

find(".label", text: "スカウト").trigger("click") # パラメータつきでURLにvisitすると何故かトップに行くので使わない

set_condition(".toggle-filter-panel", "条件で探す")

conditions = %w(エンジニア 1週間以内にログイン 関東 転職意欲が高い)

conditions.each do |condition|
  set_condition(".select-box li", condition)
end

# 年齢非公開のユーザは、学歴欄を目視確認する限り明らかに20代だと推測される場合でも、年齢絞込すると検索結果内で非表示になる
# ∴ 検索条件の段階で絞込しても、以下でプロフィールに表示される年齢を見て条件分岐しても、結果は同じ

sleep until all("article.user-profile").count >= 5 # 一度に読み込めるユーザ5件を読み込むまでsleep

all("article.user-profile").each do
  for num in 0..9 do # 1ページあたり10ユーザ
    within(all("article.user-profile")[num]) do
      if all("ul.user-activities .user-activity span")[1].text.gsub("歳", "").to_i <= 35 &&
        all("ul.user-activities .user-activity span")[1].text.gsub("歳", "").to_i >= 18
          puts all("ul.user-activities .user-activity span")[1].text
          # find(".bookmark-button").trigger("click")
          # all(".select-tag-section-body-tag", text: "エンジニア")[0].trigger("click")
      end
    end
    sleep(rand(50))
  end
end
