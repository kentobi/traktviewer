include ApplicationHelper

class SearchController < ApplicationController
	def search
		@query = params[:q]
		@magnet_link = find_serienjunkies(@query)
	end

	
end