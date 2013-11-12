require 'mechanize'
require 'logger'
require 'singleton'
require 'uri'
require 'base64'

module ApplicationHelper

	def find_serienjunkies(query)
		puts "searching serienjunkies for #{query}"
		season_string = query[-6..-1].gsub('S', '').gsub('E', '')
		puts season_string

		results_page = get("http://serienjunkies.org/search/#{query}")
		link = results_page.link_with(:href => /ul.*#{season_string}/)
		if (link != nil)
			return link.href
		end
		season_string2 = season_string.sub('0', '')
		puts "trying with new season_string: #{season_string}"
		link = results_page.link_with(:href => /ul.*#{season_string2}/)
		if (link != nil)
			return link.href
		end
		query = query[0..-8]
		puts "trying without season_string: #{query}"
		
		results_page2 = get("http://serienjunkies.org/search/#{query}")

		link = results_page2.link_with(:href => /ul.*#{season_string}/)
		if (link != nil)
			return link.href
		end
		season_string2 = season_string.sub('0', '')
		puts "trying with new season_string: #{season_string}"
		link = results_page2.link_with(:href => /ul.*#{season_string2}/)
		if (link != nil)
			return link.href
		end

		"no links found :/"
	end

	def find_torrent(query)
		begin
			piratebay_page = get("http://thepiratebay.sx/search/#{query}/0/7/0")
			first_result_href = piratebay_page.link_with(:href => /torrent/).href
			piratebay_result_page = get("http://thepiratebay.sx#{first_result_href}")
			return piratebay_result_page.link_with(:href => /magnet.*/).href
		rescue
			return "no links found"
		end
	end

	private
	def get(url)

		# initialize mechanize
		http = Mechanize.new
		http.log = Logger.new("http.log")
		proxy = ENV["http_proxy"]
		if ( proxy )
			proxy = URI.parse(proxy)
			http.set_proxy(proxy.host, proxy.port)
		end

		http.get(url)
	end
	
	class TraktApi 
		include Singleton

		def initialize
			@apikey = "9f9e025154e82b39cc9cc3987484fc50"
			@apibaseurl = "http://api.trakt.tv/"
		end
		
		def trakt_account_test(user, pass)
			get_trakt("account/test/#{@apikey}", user, pass, "POST")
		end

		def trakt_user_calendar_shows(user, pass)
			lastWeek = Date.today() - 6
			get_trakt("user/calendar/shows.json/#{@apikey}/#{user}/#{lastWeek}", user, pass)
		end

		private
		def get_trakt(url, user, pass, method = "GET")

			# initialize mechanize
			http = Mechanize.new
			http.log = Logger.new("http.log")
			proxy = ENV["http_proxy"]
			if ( proxy )
				proxy = URI.parse(proxy)
				http.set_proxy(proxy.host, proxy.port)
			end

			# add authentication
			auth = Base64.encode64("#{user}:#{pass}")
			http.request_headers = {"Authorization" => "Basic #{auth}"}

			# make request
			if method == "GET"
				http.get("#{@apibaseurl}#{url}").content
			elsif method == "POST"
				http.post("#{@apibaseurl}#{url}").content
			else
				raise "method declared was neither GET nor POST"
			end
		end
	end

end
