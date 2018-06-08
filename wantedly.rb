# 実行の前に環境変数を設定してください
# $ vim ~/.bash_profile
# export WANTEDLY_EMAIL=wantedlyに登録したemail address
# export WANTEDLY_PASS=wantedlyに登録したpassword
# write and quit
# source ~/.bash_profile

# コマンドの例
# ruby wantedly.rb eng // エンジニアの場合
# ruby wantedly.rb des // デザイナーの場合

require_relative "capybara_config"
require_relative "access_searching_page"

include CapybaraConfig
include AccessSearchingPage
include Capybara::DSL # 警告が出るが動く

CapybaraConfig.set_config

def set_condition(selector, text) # 共通
  find(selector, text: text).trigger("click")
end

def is_applicable? # 職種による
  age = all("ul.user-activities .user-activity span")[1].text.gsub("歳", "").to_i
  age.between?(18, 35)
end

def bookmark # 共通
  find(".bookmark-button").trigger("click") if find(".bookmark-button")[:class] == "bookmark-button" # 未ブクマであれば
  sleep(0.5) # wait
end

def add_non_fav
  not_engineer_group = find(".select-tag-section-body-tag", text: "_エンジニア")
  if not_engineer_group[:class] == "select-tag-section-body-tag"
    not_engineer_group.trigger("click")
  end
end

AccessSearchingPage.login
AccessSearchingPage.access_scout_page

if ARGV[0] == "eng"
  conditions = %w(エンジニア 1週間以内にログイン 関東 転職意欲が高い)
elsif ARGV[0] == "des"
  conditions = %w(デザイナー 1週間以内にログイン 関東 転職意欲が高い)
else
  puts "コマンドの末尾に正しい引数を指定してください。"
  puts "エンジニアの場合: eng, デザイナーの場合: des"
  exit!
end

conditions.each do |condition|
  set_condition(".select-box li", condition)
end

sleep(10) # 各条件指定時にsleepしない代わりにここでsleepして、ユーザ一覧を読み込む

# 年齢非公開のユーザは、学歴欄を目視確認する限り明らかに20代だと推測される場合でも、年齢絞込すると検索結果内で非表示になる
# ∴ 検索条件の段階で絞込しても、以下でプロフィールに表示される年齢を見て条件分岐しても、結果は同じ

waitings = find(".hits").text.to_i # スカウト待ち人数
actual_pages = waitings.div(10) + 1 # 1ページ(ロード)あたりスカウト待ち10人 ∴スカウト待ち人数を10で割った商+1 がリロード回数
pages = [actual_pages, 3].min # 現在の仕様だと最大3回しかループを回せないため…

if pages == 0
  puts "FORCEFULLY EXIT: There is no user remaining to add to the groups!"
  exit!
end

CSV.open("csv/users_universities.csv", "a") do |csv| # 条件を満たさないと考えられた大学. "a"はadd
  trial = 0
  pages.times do
    trial += 1
    if waitings >= 9
      for num in 0..8 do # 一回のロードにつき10名のはずだが、失敗するため9名に
        within(all("article.user-profile")[num]) do
          span_contents = all(".name .clickable-name")
          user_name = find("a.user-name").text
          user_age = all("ul.user-activities .user-activity span")[1].text

          if is_applicable? # 36歳以上の処理を飛ばすと35歳未満の最後の人への処理が重複してしまう (∵ in 0..9)
            data = CSV.read("csv/universities.csv").flatten # csvデータが1列だが2次元配列になってしまっているため


            span_contents.each do |s|

              if s.text.include?("大学") && s.text.include?("高校") == false && s.text.include?("高等学校") == false &&
                 s.text.include?("院") == false or s.text.include?("University") # 大学付属高校や大学院ではない
                 # 大学名を2回書いてしまう人には対処できないが、さすがにそんな人はなかなかいないので無視して良いかも

                  university = s.text # 出身大学名

                  if data.select {| univ | university.include?(univ) }.empty? == false # univはcsv内の大学名
                    # if ~~~ empty? で_エンジニアグループに追加すると、追加すべき人を追加し損ねてしまうため、if ~~~ empty? == false でエンジニアグループに追加

                    engineer_group = all(".select-tag-section-body-tag", text: "エンジニア")[0]

                    bookmark
                    if engineer_group[:class] == "select-tag-section-body-tag"
                      engineer_group.trigger("click")
                    end
                    puts "追加した: " + user_name + " " + university + " " + user_age

                  else
                    bookmark
                    add_non_fav
                    puts user_name + " " + university + " " + user_age + "は、条件に満たない大卒である"
                    csv << [s.text] # 条件に満たないと判断された大学を重複ありでusers_universities.csvに書き足し
                  end

              else # .clickable-name の中身が大学やUniversityではない

                bookmark
                add_non_fav
                # puts user_name + " " + user_age + " :大卒ではないか、あるいはこの要素が大卒者の職歴に関するものである"
                # .clickable-name で職歴なども取って来ざるを得ないためこうなる

              end
            end
          else
            span_contents.each do |s|
              bookmark
              add_non_fav
            end
            puts "36歳以上: " + user_name
          end

        end # within

        sleep(rand(10))

      end
    end # if waitings >= 9 に対して

    # 前回読み込み時からかなり時間が経たないとスカウト候補者リストを更新できないため、ここで時間稼ぎ
    if trial % 3 == 1 # 1回目の後
      set_condition(".select-box li", "ログイン日順")
    elsif trial % 3 == 2 # 2回目の後
      set_condition(".select-box li", "登録日順")
    elsif trial % 3 == 0 # 3回目の後 不要だが一応
      set_condition(".select-box li", "おすすめ順")
    end

    puts "Starting to sleep for a few minutes"

    random = Random.new
    sleep(random.rand(100)+10)
    # visit current_url # reload

  end
end

data = []

CSV.read("csv/users_universities.csv").flatten.uniq.each do |a|
  data << a # ユーザの卒業大学をuniqueでdataに入れる
end

new_csv = CSV.open("csv/users_universities_output.csv", "w")

data.each do |d|
  new_csv << [d] # uniqueな大学リストをcsvに出力する
end

puts "Finished successfully"
