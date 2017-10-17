class GiveawayController < ApplicationController
	def new
		puts session[:access_token]
	end

	def decide
		@winners = Giveaway.new(session[:access_token], giveaway_params).winners
		redirect_to giveaway_decision_path(winners: @winners)
	end

	def decision
		@winners = params[:winners] || []
	end

	private

	def giveaway_params
		params.require(:media_shortcode)
		params.require(:winner_count)
		params.require(:follows)
		params
	end
end
