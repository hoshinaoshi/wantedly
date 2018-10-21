require_relative "crawler"

crawler = Crawler.new

puts "以下の条件で検索します：" + crawler.conditions.join(", ") + ", 18~35歳, 大卒以上(偏差値58以上)"
puts "年齢と学歴に関して修正がある場合は、玉井までお知らせください。"

crawler.conditions.each do |condition|
  crawler.set_condition(".select-box li", condition)
end

sleep(10) # 各条件指定時にsleepしない代わりにここでsleepして、ユーザ一覧を読み込む
# 年齢非公開のユーザは、学歴欄を目視確認する限り明らかに20代だと推測される場合でも、年齢絞込すると検索結果内で非表示になる
# ∴ 検索条件の段階で絞込しても、以下でプロフィールに表示される年齢を見て条件分岐しても、結果は同じ

crawler.judge_candidates_count("scout")

CSV.open(crawler.pwd + "/csv/users_universities_#{ARGV[0]}.csv", "a") do |csv| # 条件を満たさないと考えられた大学. "a"はadd
  trial = 0
  crawler.pages.times do
    trial += 1
    if crawler.waitings >= 9
      for num in 0..8 do # 一回のロードにつき10名のはずだが、失敗するため9名に
        crawler.within(crawler.all("article.user-profile")[num]) do
          span_contents = crawler.all(".name .clickable-name")
          user_name = crawler.find("a.user-name").text
          user_age = crawler.all("ul.user-activities .user-activity span")[1].text.gsub("歳", "").to_i
          not_engineer_group = crawler.find(".select-tag-section-body-tag", text: "_#{crawler.group}")

          if crawler.is_applicable_age?(user_age)
            crawler.bookmark
            crawler.add_to_list_based_on_academic_bg(
              spans: span_contents, not_engineer_list: not_engineer_group,
              user_name: user_name, user_age: user_age, csv: csv)
          else
            span_contents.each do |s|
              crawler.bookmark
              crawler.add_non_fav(not_engineer_group)
            end
            puts "36歳以上: " + user_name
          end
        end
        sleep(rand(10))
      end
    end

    # 前回読み込み時からかなり時間が経たないとスカウト候補者リストを更新できないため、ここで時間稼ぎ
    if trial % 3 == 1 # 1回目の後
      crawler.set_condition(".select-box li", "ログイン日順")
    elsif trial % 3 == 2 # 2回目の後
      crawler.set_condition(".select-box li", "登録日順")
    elsif trial % 3 == 0 # 3回目の後 不要だが一応
      crawler.set_condition(".select-box li", "おすすめ順")
    end

    puts "Starting to sleep for a few minutes"

    random = Random.new
    sleep(random.rand(100)+10)

  end
end

data = []

CSV.read(crawler.pwd + "/csv/users_universities_#{ARGV[0]}.csv").flatten.uniq.each do |a|
  data << a # ユーザの卒業大学をuniqueでdataに入れる
end

new_csv = CSV.open(crawler.pwd + "/csv/users_universities_output_#{ARGV[0]}.csv", "w")

data.each do |d|
  new_csv << [d] # uniqueな大学リストをcsvに出力する
end

puts "Finished successfully"
