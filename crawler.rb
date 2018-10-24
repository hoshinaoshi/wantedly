require_relative "capybara_config"
require_relative "access_searching_page"

class Crawler
  include CapybaraConfig
  include AccessSearchingPage
  include Capybara::DSL

  attr_accessor :group, :conditions, :pwd, :pages, :waitings, :actual_pages

  def initialize
    set_capybara_config

    @group = case ARGV[0]
             when "eng"
               "エンジニア"
             when "des"
               "デザイナー"
             else
               raise_arg_error
               exit!
             end

    @conditions = case ARGV[1]
                  when "all"
                    %W(#{@group} 1週間以内にログイン 転職意欲が高い)
                  when "kanto"
                    %W(#{@group} 1週間以内にログイン 関東 転職意欲が高い)
                  else
                    raise_arg_error
                    exit!
                  end

    @pwd = Dir.pwd.include?("/wantedly") ? Dir.pwd : Dir.pwd + "/wantedly"
    # コマンドラインから実行 or crontabから実行
    
    login
    access_scout_page
  end

  def set_condition(selector, text) # 共通
    find(selector, text: text).trigger("click")
  end

  def judge_candidates_count(arg)
    # スカウト待ち人数
    @waitings = (arg == "scout" ? find(".hits") : find(".bookmarked-user-info-number-caution-count")).text.to_i

    @actual_pages = @waitings.div(10) + 1 # 1ページ(ロード)あたりスカウト待ち10人 ∴スカウト待ち人数を10で割った商+1 がリロード回数
    @pages = [actual_pages, 3].min # 現在の仕様だと最大3回しかループを回せないため…
    
    if pages == 0
      puts "これ以上リストに追加できる候補者はいませんでした。"
      exit!
    end
  end

  def is_applicable_age?(age)
    age.between?(18, 35)
  end

  def is_applicable_background?(text)
    text.include?("大学") && text.include?("高校") == false &&
    text.include?("高等学校") == false && text.include?("院") == false or
    text.include?("University")
  end

  def bookmark # 共通
    find(".bookmark-button").trigger("click") if find(".bookmark-button")[:class] == "bookmark-button" # 未ブクマであれば
    sleep(0.5) # wait
  end

  def add_non_fav(not_engineer_group)
    return if not_engineer_group[:class] == "select-tag-section-body-tag selected"
    not_engineer_group.trigger("click")
  end

  def add_to_list_based_on_academic_bg(spans:, not_engineer_list:, user_name:, user_age:, csv:)
    csv_data = CSV.read(@pwd + "/csv/universities.csv").flatten
    spans.each do |s|
      add_non_fav(not_engineer_list) and next unless is_applicable_background?(s.text)

      university = s.text

      if csv_data.select { |csv_univ| university.include?(csv_univ) }.empty? == false
        # if ~~~ empty? で_エンジニアグループに追加すると、追加すべき人を追加し損ねてしまうため、if ~~~ empty? == false でエンジニアグループに追加

        engineer_group = all(".select-tag-section-body-tag", text: "エンジニア")[0]

        engineer_group.trigger("click") if engineer_group[:class] == "select-tag-section-body-tag"
        puts "追加した: " + user_name + " " + university + " " + user_age.to_s + "歳"

      else
        add_non_fav(not_engineer_list)
        puts user_name + " " + university + " " + user_age.to_s + "歳 は、条件に満たない大卒である"

        # 条件に満たないと判断された大学を重複ありでusers_universities.csvに書き足し
        csv << [s.text] unless csv.nil?
      end
    end
  end

  def raise_arg_error
    puts "コマンドの末尾に正しい引数を指定してください。"
    puts "エンジニアの第一引数: eng, デザイナーの第一引数: des"
    puts "関東に絞り込む場合の第二引数: kanto, 全国から探す場合の第二引数: all"
  end
end
