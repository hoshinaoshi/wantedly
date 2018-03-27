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


def set_condition(selector, text)
  find(selector, text: text).trigger("click")
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

sleep(5) # 各条件指定時にsleepしない代わりにここでsleepして、ユーザ一覧を読み込む

# 年齢非公開のユーザは、学歴欄を目視確認する限り明らかに20代だと推測される場合でも、年齢絞込すると検索結果内で非表示になる
# ∴ 検索条件の段階で絞込しても、以下でプロフィールに表示される年齢を見て条件分岐しても、結果は同じ

waitings = find(".hits").text.to_i # スカウト待ち人数
pages = waitings.div(10) + 1 # 1ページ(ロード)あたりスカウト待ち10人 ∴スカウト待ち人数を10で割った商+1 がリロード回数

pages.times do
  for num in 0..9 do # 一回のロードにつき10名
    within(all("article.user-profile")[num]) do
      if is_applicable? # 36歳以上の処理を飛ばすと35歳未満の最後の人への処理が重複してしまう (∵ in 0..9)
        data = CSV.read("universities.csv").flatten # csvデータが1列だが2次元配列になってしまっているため

        span_contents = all(".name .clickable-name")
        user_name = find("a.user-name").text
        user_age = all("ul.user-activities .user-activity span")[1].text

        span_contents.each do |s|

          if s.text.include?("大学") || s.text.include?("University") # 最終学歴が大学・大学院であれば
            university = s.text # 出身大学名
            if data.select {| univ | university.include?(univ) }.empty? # univはcsv内の大学名
              find(".bookmark-button").trigger("click") # お気に入りリストに追加
              find(".select-tag-section-body-tag", text: "_エンジニア").trigger("click")
              puts user_name + " " + university + " " + user_age + "は、条件に満たない大卒である"
            else
              find(".bookmark-button").trigger("click") # お気に入りリストに追加
              find(".select-tag-section-body-tag", text: "エンジニア").trigger("click")
              puts "追加した: " + user_name + " " + university + " " + user_age
            end
          else # .clickable-name の中身が大学やUniversityではない
            find(".bookmark-button").trigger("click") # お気に入りリストに追加
            find(".select-tag-section-body-tag", text: "_エンジニア").trigger("click")
            puts user_name + " " + user_age + " :大卒ではないか、あるいはこの要素が大卒者の職歴に関するものである"
            # .clickable-name で職歴なども取って来ざるを得ないためこうなる
            # putsの回数は、.clickable-name がついた要素の個数に依存する
          end
          # 院卒の人は必然的に大卒(なはず)なので、処理がダブってしまいお気に入り登録できなくなるかも
          # 大学付属の高校まで取ってきてしまうのも問題
          # 大学名を2回書いてしまう人には対処できないが、さすがにそんな人はなかなかいないので無視して良いかも

        end

      else
        puts "35歳以上: " + user_name
      end

    end

    sleep(rand(50))

  end

  visit current_path # reload
  sleep(10)

end
