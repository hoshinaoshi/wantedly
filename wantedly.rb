require "capybara"
require "capybara/dsl"
require "capybara/poltergeist"
require "csv"

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


def set_condition(selector, text)
  find(selector, text: text).trigger("click")
  # ブクマボタンの表示までsleepさせていたが、clickが早すぎると条件絞込後ユーザ一覧を読み込む前のブクマボタンの存在を認識してしまうため、
  # ここではsleepしないことにした
end

def is_applicable?
  age = all("ul.user-activities .user-activity span")[1].text.gsub("歳", "").to_i
  age.between?(18, 35)
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

sleep(10) # 各条件指定時にsleepしない代わりにここでsleepして、ユーザ一覧を読み込む

# 年齢非公開のユーザは、学歴欄を目視確認する限り明らかに20代だと推測される場合でも、年齢絞込すると検索結果内で非表示になる
# ∴ 検索条件の段階で絞込しても、以下でプロフィールに表示される年齢を見て条件分岐しても、結果は同じ
puts all("article.user-profile").count
page.save_screenshot("~/Downloads/2.png", full: true)

for num in 0..9 do
  within(all("article.user-profile")[num]) do
    next unless is_applicable? # 36歳以上は処理を飛ばす
    puts find(".user-name").text
    data = CSV.read("universities.csv").flatten # csvデータが1行だが2次元配列になってしまっているため
    all(".clickable-name").each do |span|
      # 学歴欄にユニークなidやある程度ユニークなclassが存在しないため、「大学」という文字列が含まれる.clickable-name総当たりで調べる
      span_content = span.text
      if span_content.include?("大学") # 「最終学歴が大学であれば」
        # 大学名を英語表記で書いている場合や外国大学の場合、またデータ取得元にそもそも載っていない場合、切り捨ててしまう。
        # （切り捨てたユーザをのちに採用担当者が改めて目にする機会があるのであればさほど問題ではないが、「英語表記の大学or海外大学orデジハリなど新しい大学 を考慮しないことで良い候補者を取り逃がしてしまう」可能性は、「学歴フィルタをかけることにより学歴がない逸材を切り捨ててしまう」可能性よりももっと高いだろうから、問題である。）
        univ = span_content
        user_name = find("a.user-name").text
        user_age = all("ul.user-activities .user-activity span")[1].text
        if data.include?(univ)
          # find(".bookmark-button").trigger("click") # お気に入りリストに追加
          # all(".select-tag-section-body-tag", text: "エンジニア")[0].trigger("click")
          puts "ADDED " + user_name + " " + univ + " " + user_age
        else
          puts "DIDNT ADD " + user_name + " " + univ + " " + user_age
        end
      end
    end
  end
  sleep(rand(5))
end
