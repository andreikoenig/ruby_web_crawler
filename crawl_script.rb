# email nv1982@gmail.com if you have any questions about this script
# Twitter: @andreikoenig
# andreikoenig.blogspot.com  my blog


require 'anemone'
require 'benchmark'
require 'net/http'


def get_url
	print "http://"
	user_url = gets.chomp
	"http://" + user_url
end

def check_url
	url = get_url
	res = nil
	while res == nil
		begin
			puts "Checking if #{url} is a valid URL. Please wait..."
			res = Net::HTTP.get_response(URI(url))
		rescue StandardError
			puts "An error occured, please check your URL and try again:"
			url = get_url
		end
	end
	url
end

urls = []

puts "What website would you like to crawl?"
url = check_url

puts "What depth level would you like to crawl?"
print "> "
depth = gets.chomp
puts "Preparing to crawl #{url} with the depth level of #{depth}"
puts "Please wait, crawling..."
filter_array = [".JPG", ".pdf", ".jpg", ".jpeg", ".gif", ".png"]
time = Benchmark.measure do
	Anemone.crawl("#{url}", :depth_limit => depth.to_i) do |anemone|
		anemone.on_every_page do |page|
			if page.code.to_s != "301"
				urls.push(page.url) unless filter_array.any? { |x| page.url.to_s.include?(x)}
				if urls.length % 100 == 0
					puts "\n#{urls.length} links found so far. Please wait, crawling..."
				end
				if urls.length % 6 == 0
					print ". "
				end
			end
		end
	end
end
puts "\nIt took #{time.real.round(2)} sec for the script to crawl #{url}."

print "The crawler returned #{urls.length} links."

if urls != urls.uniq
	puts "Duplicate links found. "
	dupl = true
else
	puts "There are no duplicate links found."
end

while dupl == true
	puts "Would you like to delete duplicate links? yes/no"
	input = gets.chomp.downcase
	if input == "yes"
		urls.uniq!
		break
	elsif input == "no"
		break
	else
		puts "Only yes or no answer expected."
	end
end
puts "Crawl results written to crawl_result.txt file."
File.open("crawl_result.txt", "w"){|file| file.puts urls}
