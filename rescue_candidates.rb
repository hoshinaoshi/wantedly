require_relative "crawler"

crawler = Crawler.new
crawler.find(".scout-bookmarked-users-button").trigger("click")
crawler.all(".tag-manager-tag", text: "_エンジニア")[0].trigger("click")
crawler.judge_candidates_count("rescue")

trial = 0
crawler.pages.times do
  trial += 1
  if crawler.waitings >= 9
    for num in 0..8 do # 一回のロードにつき10名のはずだが、失敗するため9名に
      crawler.within(crawler.all("article.user-profile")[num]) do
        span_contents = crawler.all(".name .clickable-name")
        user_name = crawler.find("a.user-name").text
        user_age = crawler.all("ul.user-activities .user-activity span")[1].text.gsub("歳", "").to_i
        ng_engineer_group = crawler.find(".select-tag-section-body-tag", text: "エンジニア_NG")
        not_engineer_group = crawler.all(".select-tag-section-body-tag", text: "_エンジニア")[0]

        if crawler.is_applicable_age?(user_age)
          crawler.bookmark
          crawler.add_to_list_based_on_academic_bg(
            spans: span_contents, list: ng_engineer_group,
            user_name: user_name, user_age: user_age, csv: nil)
          not_engineer_group.trigger("click") if ng_engineer_group[:class] == "select-tag-section-body-tag selected"
        else
          span_contents.each do |s|
            crawler.bookmark
            crawler.add_non_fav(ng_engineer_group)
            not_engineer_group.trigger("click") if not_engineer_group[:class] == "select-tag-section-body-tag selected"
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
