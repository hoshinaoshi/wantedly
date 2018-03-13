require "mechanize"
require "open-uri"
require "net/http"
require "nokogiri"

agent = Mechanize.new
agent.user_agent = "Windows Mozilla"

agent.get('https://www.wantedly.com/user/sign_in') do |loginpage|
  response = loginpage.form_with(:dom_id => 'new_user') do |form|
    form.field_with(:name => 'user[email]').value = ARGV[0]
    form.field_with(:name => 'user[password]').value = ARGV[1]
  end.submit
  p "submitted"

  agent.get("https://www.wantedly.com/enterprise/scouts#search%5Bkeywords%5D=&search%5Boccupation_types%5D%5B%5D=engineer&search%5Bactivity%5D=7&search%5Blocations%5D%5B%5D=kanto&search%5Bmotivation%5D=large&search%5Bscout_reply%5D=&search%5Bconnection%5D=&search%5Bscout_received%5D=&search%5Bage_range%5D=18-35&search%5Bgraduation_year%5D=&search%5Border%5D=recommend&search%5Bcountries%5D%5B%5D=japan&search%5Brecommended%5D=false&search%5Bbookmarked_users_params%5D=&filter_is_used=true") do |page|

    html = Nokogiri::HTML.parse(page.body)
    puts html

  end

end
