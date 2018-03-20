require "nokogiri"
require "open-uri"
require "csv"

# CSV.open("universities-pri.csv", "w") do |csv|
#
#   uris = %w(/zenkokushirituranking1.html /zenkokushiriturankong2.html) #国公立
#   # uris = %w(/zenkokukokkourituranking1.html /zenkokukokkourituranking2.html) #私立
#   uris.each do |uri|
#     html = open( "http://daigakujyuken2.boy.jp/" + uri )
#     doc = Nokogiri::HTML.parse(html,nil,"UTF-8")
#     doc.css("b a").each do |a|
#         univ = a.inner_text
#         puts univ
#         csv << [univ]
#         sleep(1)
#     end
#   end
# end

CSV.read("universities.csv").each do |u|
  puts u
  sleep(1)
end
