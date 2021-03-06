class UserCompletionsController < ApplicationController
	  protect_from_forgery with: :null_session
	  before_action :authenticate_user!, only:[:generate_doughnut_chart_data, :generate_radar_chart_data, :generate_line_chart_data]

	def generate_doughnut_chart_data
		@user = current_user
		@start_date = ""
		if params[:start_date]
			@start_date = params[:start_date] 
		else
			@start_date = @user.created_at
		end
		user_completions = @user.user_completions.where("created_at > ?", @start_date)
		task_data = {}
		user_completions.each do |label|
			# print task_data
			if !task_data.include?(label.task.name)
				task_data[label.task.name] = 1
			else
				task_data[label.task.name] += 1
			end
		end

		render json: task_data
	end

	def generate_radar_chart_data
		@user = current_user
		@start_date = ""
		if params[:start_date]
			@start_date = params[:start_date] 
		else
			@start_date = @user.created_at
		end
		user_completions = @user.user_completions.where("created_at > ?", @start_date)
		completion_data = {}
		user_completions.each do |label|
			print completion_data
			if !completion_data.include?(label.task.name)
				completion_data[label.task.name] = 1
			else
				completion_data[label.task.name] += 1
			end
		end

		# user_attempts = @user.user_completions.where(!:completed)
		user_attempts = @user.user_completions.where(:completed => true).where("created_at > ?", @start_date) 
		# user_attempts = @user.user_completions.where("created_at > ? AND :completed => ?", @start_date, false)
		attempt_data = {}
		user_attempts.each do |label|
			# print attempt_data
			if !attempt_data.include?(label.task.name)
				attempt_data[label.task.name] = 1
			else
				attempt_data[label.task.name] += 1
			end
		end

		task_labels_array = @user.tracks.last.tasks
		task_labels = []
		task_labels_array.each do |label|
			task_labels.push(label.name)
		end

		render json: [completion_data, attempt_data, task_labels]
	end

	def generate_bar_chart_data
		@user = current_user
		@start_date = ""
		if params[:start_date]
			@start_date = params[:start_date] 
		else
			@start_date = @user.created_at
		end
		user_completions = @user.user_completions.where("created_at > ?", @start_date)
		task_data = {}
		user_completions.each do |label|
			# print task_data
			if !task_data.include?(label.task_type.name)
				task_data[label.task_type.name] = 1
			else
				task_data[label.task_type.name] += 1
			end
		end

		render json: task_data
	end

	def generate_line_chart_data
		@user = current_user
		@start_date = ""
		if params[:start_date]
			@start_date = params[:start_date] 
		else
			@start_date = @user.created_at
		end
		user_completions = @user.user_completions.where("created_at > ?", @start_date)
		task_data = {}
		user_completions.each do |label|
			# print task_data
			if !task_data.include?(label.task_type.name)
				task_data[label.task_type.name] = 0
			else
				task_data[label.task_type.name] += 1
			end
		end


		render json: [task_data]
	end

	def generate_test_reps
		@user = User.last
		@start_date = ""
		if params[:start_date]
			@start_date = params[:start_date] 
		else
			@start_date = @user.created_at
		end
		user_completions = @user.user_completions.where("created_at > ?", @start_date)
		task_data = {}
		user_completions.each do |label|
			# print task_data
			if !task_data.include?(label.task_type.name)
				task_data[label.task_type.name] = 1
			else
				task_data[label.task_type.name] += 1
			end
		end

		rep_count = {}
		user_completions.each do |task|
			if !rep_count.include?(task.task_type.name)
				rep_count[task.task_type.name] = task.task_count
			else
				rep_count[task.task_type.name] += task.task_count
			end
		end


		render json: rep_count

	end


	def index
		user_completions = current_user.user_completions
		task_type = user_completions.task_type.name

		render json: task_type
	end

	def create
		user_completion = UserCompletion.create(user_completion_params)
		render json: user_completion
	end

	def show
		user_completion = UserCompletion.find_by(id: params[:id])
		task_type = user_completion.task_type.name
		task = user_completion.task.name
		completion_info = [user_completion, task_type, task]
		unless user_completion
			render json: {error: "User completion not found"},
				status: 404
			return
		end
		render :json => completion_info				
	end

	private

	def user_completion_params
		params.require(:user_completion)
			.permit(:user_id, :track_id, :task_id, :task_type_id)
	end

	# def not_completed
	# 	@user.user_completions.completed => false
	# end
end
