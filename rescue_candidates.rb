require_relative "crawler"

crawler = Crawler.new
crawler.find(".scout-bookmarked-users-button").trigger("click")
crawler.all(".tag-manager-tag", text: "_エンジニア")[0].trigger("click")
crawler.judge_candidates_count("rescue")

crawler.actual_pages.times do
  if crawler.waitings >= 9
    for num in 0..8 do # 一回のロードにつき10名のはずだが、失敗するため9名に
      crawler.within(crawler.all("article.user-profile")[num]) do
        span_contents = crawler.all(".name .clickable-name")
        user_name = crawler.find("a.user-name").text
        user_age = crawler.all("ul.user-activities .user-activity span")[1].text.gsub("歳", "").to_i
        engineer_group = crawler.all(".select-tag-section-body-tag", text: "エンジニア")[0]
        ng_engineer_group = crawler.find(".select-tag-section-body-tag", text: "エンジニア_NG")
        not_engineer_group = crawler.all(".select-tag-section-body-tag", text: "_エンジニア")[0]

        if crawler.is_applicable_age?(user_age)
          crawler.open_bookmark
          crawler.add_to_list_based_on_academic_bg(
            spans: span_contents, not_engineer_list: not_engineer_group,
            user_name: user_name, user_age: user_age, csv: nil)

          not_engineer_group.trigger("click") if
            not_engineer_group[:class] == "select-tag-section-body-tag selected" ||
            engineer_group[:class] == "select-tag-section-body-tag selected"
        else
          span_contents.each do |s|
            crawler.open_bookmark
            crawler.add_non_fav(ng_engineer_group)
            crawler.add_non_fav(not_engineer_group)

            not_engineer_group.trigger("click") if
              not_engineer_group[:class] == "select-tag-section-body-tag selected" &&
              ng_engineer_group[:class] == "select-tag-section-body-tag selected"
          end
          puts "36歳以上: " + user_name
        end
      end
      sleep(rand(10))
    end
  end
  sleep(rand(10)+5)
end
