require 'capybara'
require 'capybara/dsl'
require 'capybara/poltergeist'
require 'nokogiri'
require 'open-uri'

Capybara.current_driver = :poltergeist

Capybara.configure do |config|
    config.run_server = false
    config.javascript_driver = :poltergeist
    config.app_host = "https://www.wantedly.com"
    config.default_max_wait_time = 60
    config.ignore_hidden_elements = false
end

Capybara.register_driver :poltergeist do |app|
    Capybara::Poltergeist::Driver.new(app, {:timeout=>120, :js=>true, :js_errors=>false, :headers=>{ 'HTTP_USER_AGENT' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/XXXXXXXXXXXXX Safari/XXXXXX Vivaldi/XXXXXXXXXX'}})
end


module Crawler
  class Bluemix

    include Capybara::DSL

    def login(username, password)
      page.driver.headers = { "User-Agent" => "Mac Safari" }

      visit('/user/sign_in')

      # page.first('.ui-show-modal').trigger('click')

      fill_in "user[email]", :with => username, match: :first
      fill_in "user[password]", :with => password

      page.all(".wt-ui-button-blue")[0].trigger('click')
      puts page.all(".wt-ui-button-blue")[0].value
    end

    def select#(region, org)
      # 地域と組織の管理画面へ遷移
      page.driver.headers = { "User-Agent" => "Mac Safari" }

      # page.all("div.label")[6].trigger('click')
      session = Capybara::Session.new(:poltergeist)


      # opt = {}
      # opt['User-Agent'] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/XXXXXXXXXXXXX Safari/XXXXXX Vivaldi/XXXXXXXXXX'

      url = 'https://www.wantedly.com/enterprise/scouts'
      
      session.visit(url)

      # visit("/enterprise/scouts")

      # page.all(".label")[6].trigger("click")

      puts page.find("body")['outerHTML'] # htmlタグ出力
      p URI.parse(current_url).to_s

      # puts page.find(".toggle-filter-panel")
      # puts page.all(".user-name")[0].value

      # 右上顔マークのclickトリガーでajax発生
      # p page.find('title')

        # html = open(url, opt)
        # doc = Nokogiri::HTML.parse(html)
        # puts doc

      # puts all('div.bookmark-button')
      # find("div.bookmark-button").trigger('click')

      # 地域用画面へ遷移
      # 該当の下矢印のclickトリガーでajax発生
      # find("img.toggle-region-expand").trigger('click')
      # find_all("p.select-name").each do |name|
      #   if name.text == region
      #     puts "clicked #{name.text}"
      #     name.trigger('click')
      #   end
      # end

      # 組織用画面へ遷移
      # 該当の下矢印のclickトリガーでajax発生
      # find("img.toggle-org-expand").trigger('click')
      # find_all("p.select-name").each do |name|
      #   if name.text == org
      #     puts "clicked #{name.text}"
      #     name.trigger('click')
      #   end
      # end
    end

    # def report
    #   # 課金情報を閲覧できるアカウントリンクをクリック
    #   find("a.account-link").trigger('click')
    #
    #   # サービスの右矢印をすべてクリックして情報開示
    #   find_all("span.i-arrow-right-dark-blue").each do |name|
    #       puts "clicked blue #{name.text}"
    #       name.trigger('click')
    #   end
    #
    #   # サービスの配下に出てきたインスタンスの右矢印をすべてクリックして情報開示
    #   find_all("span.i-arrow-right-white").each do |name|
    #       puts "clicked white #{name.text}"
    #       name.trigger('click')
    #   end
    #
    #   # HTMLの描画を待つ
    #   # find系コマンドが続く場合はjquery応答中は描画を待ってくれる
    #   wait_for_ajax
    #   sleep 30
    #
    #   #html = open(Capybara.app_host)
    #   #doc = Nokogiri::HTML.parse(html)
    #   #puts doc
    #   puts doc.xpath("//div[@class='chargesDetailsServicesContainer hideHeaderLabels']")
    #
    #   page.save_screenshot('screenshot.png', :full => true)
    # end
    #
    #
    # def wait_for_ajax
    #   sleep 2
    #   Timeout.timeout(Capybara.default_max_wait_time) do
    #     active = page.evaluate_script('jQuery.active')
    #     until active == 0 || active == nil
    #       sleep 1
    #       active = page.evaluate_script('jQuery.active')
    #       end
    #     end
    #   end
    #
    end
end

crawler = Crawler::Bluemix.new
crawler.login(ARGV[0], ARGV[1])
crawler.select#("米国南部", "組織名")
# crawler.report
