require 'uri'
require 'json'
require 'date'

include ApplicationHelper

class HomeController < ApplicationController

	def index

		# if not logged in -> redirect to login-page
		username = cookies[:username]
		if not username
			return redirect_to "/config"
		end

		result = TraktApi.instance.trakt_user_calendar_shows(cookies[:username], cookies[:password])
		result = JSON.parse(result)
		#puts JSON.pretty_generate(result)

		@calendar = result

	end
end
