class DashboardController < ApplicationController
  before_action :verified_user_has_profile?

	def main
		# @user = User.find_by(params[:id])
		completions = UserTrackCompletionAssociation.where(user_id: current_user.id)
		@completed = []
		@attempted = []
		completions.each do |completion|
			if completion.completed
				@completed.push(completion)
			end
			@attempted.push(completion)
		end

		@completion_percentage = (@completed.count.to_f/@attempted.count.to_f) * 100
	end

	protected
	
	def verified_user_has_profile? 
  		if current_user && !current_user.profile
  			redirect_to new_profile_path
  		end
  	end
end
