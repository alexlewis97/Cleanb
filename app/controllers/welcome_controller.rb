class WelcomeController < ApplicationController
	def home
		#WorkTask.all.select{|wt| wt.start_time.beginning_of_day < DateTime.now.beginning_of_day}.each do |wt| 
			#wt.delete
		#end	
		if Task.all != nil 
			
		end
	end
	
	def tomorrow_task 
		@tasks = Task.all.select{|task| task.start_time > DateTime.now.tomorrow.beginning_of_day && task.start_time < DateTime.now.tomorrow.end_of_day}
		@tasks_temp = Task.all.select{|task| task.status != "finished" && task.start_time < DateTime.now.tomorrow.beginning_of_day && task.end_time > DateTime.now.tomorrow.beginning_of_day}
		@tasks = (@tasks + @tasks_temp)
		@tasks = @tasks.sort_by{|task| [task.end_time]}
	end
	
	def des 
	end
	
	def import_reservations_file
	end
	
	def change_status_to_finish
		@task = Task.find(params[:id])
		@task.status = "finished"
		@task.save
		redirect_to root_url
	end
	
	def change_status_to_finish_via_employee
		@task = Task.find(params[:id])
		@task.status = "finished"
		@task.save
		redirect_to welcome_employee_path
	end
	
	def change_all_to_finish
		@tasks = Task.all.select{|task| task.start_time > DateTime.now.beginning_of_day && task.start_time < DateTime.now.end_of_day}
		@tasks_temp = Task.all.select{|task| task.status != "finished" && task.start_time < DateTime.now.beginning_of_day && task.end_time > DateTime.now.beginning_of_day}
		@tasks = (@tasks + @tasks_temp)
		@tasks = @tasks.sort_by{|task| [task.end_time]}
		@tasks.each do |task|
			task.status = "finished"
			task.save
		end
		redirect_to root_path
	end
	
	def employee_help(work_tasks)
		work_tasks.each do |work_task|
				if work_task.task_id > 0
					return true
				end	
		end
		return false
	end
	
	def employee
		@employees = Array.new
		Employee.all.each do |employee| 
			@work_day = WorkDay.all.where(employee_id: employee.id , start_time: [DateTime.now.beginning_of_day..DateTime.now.end_of_day])
			@work_tasks = WorkTask.all.where(work_day_id: @work_day)
			@work_tasks = @work_tasks.sort_by {|work_task| [work_task.start_time.hour.to_i]}
			if employee_help(@work_tasks)
				@employees.push(employee)
			end
		end
		@unassigned_tasks = Task.all.select{|task| task.start_time < DateTime.now.end_of_day && task.end_time > DateTime.now.beginning_of_day && (task.status == "error")}
	end
	
end
