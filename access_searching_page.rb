module AccessSearchingPage
  require "capybara"
  require "capybara/dsl"
  require "capybara/poltergeist"
  require "csv"
  require "pry"

  include Capybara::DSL # 警告が出るが動く

  def login
    visit("/user/sign_in")

    fill_in "user[email]", with: ARGV[0], match: :first # 同様のname属性を持つタグが他にあるため、この場合最初にマッチするものを探す
    fill_in "user[password]", with: ARGV[1]

    all(".wt-ui-button-blue")[0].trigger("click") # ログインボタン
    puts "Successfully logged in"
  end

  def access_scout_page
    find(".label", text: "スカウト").trigger("click") # パラメータつきでURLにvisitすると何故かトップに行くので使わない
    set_condition(".toggle-filter-panel", "条件で探す")
  end

end
