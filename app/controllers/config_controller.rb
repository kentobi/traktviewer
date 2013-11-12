include ApplicationHelper

class ConfigController < ApplicationController

	def index
		username = cookies[:username]
		if username
			@logged_in = true
		else
			@logged_in = false
		end
	end

	def login
		username = params[:username]
		password = params[:password]

		begin
			TraktApi.instance.trakt_account_test(username, password)

			cookies.permanent[:username] = username
			cookies.permanent[:password] = password

			redirect_to "/"
		rescue Mechanize::UnauthorizedError
			@login_failed = true
			render "index"
		end
			
	end

	def logout
		cookies.delete :username
		cookies.delete :password
		render "index"
	end

end