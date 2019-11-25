class TasksController < ApplicationController
	def new
		@task = Task.new
	end
	
	def create
		@task = Task.new
		
		#type of task conversion from params
		@task.type_of_task = params[:task][:type_of_task]
		
		#start_time converting from hash to datetime
		@task.start_time= DateTime.new(
		params[:task]["start_time(1i)".to_sym].to_i,
		params[:task]["start_time(2i)".to_sym].to_i,
		params[:task]["start_time(3i)".to_sym].to_i,
		params[:task]["start_time(4i)".to_sym].to_i,
		params[:task]["start_time(5i)".to_sym].to_i)
		
		#end_time converting from hash to datetime
		@task.end_time= DateTime.new(
		params[:task]["end_time(1i)".to_sym].to_i,
		params[:task]["end_time(2i)".to_sym].to_i,
		params[:task]["end_time(3i)".to_sym].to_i,
		params[:task]["end_time(4i)".to_sym].to_i,
		params[:task]["end_time(5i)".to_sym].to_i)
		
		#flat_id conversion from params
		@task.flat_id = params[:task][:flat_id]
		
		if !(Task.all.select{|t| t.start_time.day == @task.start_time.day && t.flat_id == @task.flat_id}.any?)
			@task.save
		else 
			render 'new'
		end
	end
	
	def show
		@task = Task.all.find(params[:id])
	end
	 
	def index
		@tasks = Task.all
		@tasks = @tasks.sort_by {|task| [task.start_time, task.end_time]}
	end
	
	def update 
		@task = Task.all.find(params[:id])
		
		@task.start_time= DateTime.new(
		params[:task]["start_time(1i)".to_sym].to_i,
		params[:task]["start_time(2i)".to_sym].to_i,
		params[:task]["start_time(3i)".to_sym].to_i,
		params[:task]["start_time(4i)".to_sym].to_i,
		params[:task]["start_time(5i)".to_sym].to_i)
		
		#end_time converting from hash to datetime
		@task.end_time= DateTime.new(
		params[:task]["end_time(1i)".to_sym].to_i,
		params[:task]["end_time(2i)".to_sym].to_i,
		params[:task]["end_time(3i)".to_sym].to_i,
		params[:task]["end_time(4i)".to_sym].to_i,
		params[:task]["end_time(5i)".to_sym].to_i)
		
		@task.save
		
		#need to update the reservations
		@reservation = Reservation.find{|rester| reser.flat_id == @task.flat_id && reser.check_out.end_of_day == @task.start_time.end_of_day}
		if(@reservation)
			@reservation.check_out = @task.start_time
			@reservation.save
		end
		@reservation = Reservation.find{|reser| reser.flat_id == @task.flat_id && reser.check_in.end_of_day == @task.end_time.end_of_day}
		if(@reservation)
			@reservation.check_in = @task.end_time
			@reservation.save
		end
		redirect_to root_url
	end
	
	def edit
		@task = Task.find(params[:id])
	end
	
	def change_status_to_finish_via_home
		@task = Task.find(params[:id])
		@task.status = "finished"
		@task.save
		redirect_to root_url
	end
	
	def import 		
		Task.import(params[:file])		
	end
	
	def destroy
		@task = Task.find(params[:id])
		@task.destroy
		flash[:notice] = "Task was successfully deleted"
		redirect_to root_path
	end
	
	def add_tasks(old_tasks, new_tasks)
	end
	
	
	def update_tasks
		Task.delete_all
		#here we need to change the code and change it to delete tasks only if they are different 
		#we need to update all the tasks for the flats
		@reservations = Reservation.all
		@tasks = Array.new
		@flats = Flat.all
		@flats.each do |flat|
			if(@reservations.where(flat_id: flat.id))
				@flat_reservations = @reservations.where(flat_id: flat.id)
				counter = 0
				(1..@flat_reservations.length-1).each do
					@task = Task.new
					@task.start_time = @flat_reservations[counter].check_out
					@task.end_time = @flat_reservations[counter + 1].check_in
					@task.flat_id = @flat_reservations[counter].flat_id
					@task.status = "unassigned"
					counter = counter + 1
					@tasks.push(@task)
				end
				#task.start_time = @flat_reservations[counter].check_out
				#task.end_time = @flat_reservations[counter].check_out.change(year: @flat_reservations[counter].check_out.year.to_i + 1)				
				#task.flat_id = @flat_reservations[counter].flat_id
			end
		end
		ActiveRecord::Base.transaction do
			@tasks.each do |task|
				task.save
			end
		end
		redirect_to root_url
	end

end
