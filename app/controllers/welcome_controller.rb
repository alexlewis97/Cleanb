class WelcomeController < ApplicationController
	def home
		@tasks = Task.all.select{|task| task.start_time > DateTime.now.beginning_of_day && task.start_time < DateTime.now.end_of_day}
		@tasks_temp = Task.all.select{|task| task.status != "finished" && task.start_time < DateTime.now.beginning_of_day && task.end_time > DateTime.now.beginning_of_day}
		@tasks = (@tasks + @tasks_temp)
		@tasks = @tasks.sort_by{|task| [task.end_time]}
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
	end
	
	
	def search_first(task, work_tasks)
		work_tasks.each do |work_task|
			if work_task.start_time >= task.start_time && work_task.end_time <= task.end_time && work_task.task_id == 0 
				work_task.task_id = task.id
				return true
			end	
		end
		return false
	end
	
	def assign_tasks(tasks, work_tasks)
		#now we need to iterate the tasks
		counter = 0
		tasks.each do |task|
			#what we need to do here is for the task to take the first slot available
			if(search_first(task, work_tasks))
				counter = counter + 1 
			end
		end
		return counter
	end
	
	
	def search_first_with_save(task, work_tasks)
		work_tasks.each do |work_task|
			if work_task.start_time >= task.start_time && work_task.end_time <= task.end_time && work_task.task_id == 0 
				work_task.task_id = task.id
				work_task.save
				return true
			end	
		end
		return false
	end
	
	def assign_tasks_with_save(tasks, work_tasks)
		tasks.each do |task|
			search_first_with_save(task, work_tasks)
	end
	
	def sort_end_first(tasks)
		tasks = tasks.sort_by{|task| [task.end_time]}
	end
	
	def sort_start_first
		tasks = tasks.sort_by{|task| [task.start_time]}
	end
	
	def sort_smallest_slot(tasks)
		tasks = tasks.sort_by{|task| [(task.end_time.hour.to_i - task.start_time.hour.to_i) + (1/60 * (task.end_time.min.to_i - task.start_time.min.to_i)) , task.end_time , task.start_time]}
	end
		
	def schedule_tasks_help(tasks, rest_of_tasks, work_tasks)
		#for each of the tasks we should have a counter
		counter1 = assign_tasks(sort_smallest_slot(tasks), work_tasks)
		counter2 = assign_tasks(sort_start_first(tasks), work_tasks)
		counter3 = assign_tasks(sort_end_first(tasks), work_tasks)
		
		if counter1 == counter2 && counter1 == counter3
			assign_tasks_with_save((sort_smallest_slot(tasks) + sort_end_first(rest_of_tasks)),work_tasks) 
			return true
		end
		
		if counter1 > counter2 && counter1 > counter3
			assign_tasks_with_save((sort_smallest_slot(tasks) + sort_end_first(rest_of_tasks)),work_tasks) 
			return true
		end
		
		if counter2 > counter1 && counter2 > counter3
			assign_tasks_with_save((sort_start_first(tasks) + sort_end_first(rest_of_tasks)),work_tasks)
			return true
		end
		
		if counter3 > counter1 && counter3 > counter2
			assign_tasks_with_save((sort_end_first(tasks) + sort_end_first(rest_of_tasks)),work_tasks)		
			return true
		end
		
	end
		
	def schedule(sch_day)
		
		counter = 1
		(1..15).each do
			Employee.delete_all
			@employee = Employee.new
			@employee.name = "name" + counter
			counter = counter + 1 
			@employee.save
			@work_day = WorkDay.new
			@work_day.start_time = sch_day.change(hour: 8, min: 0)
			@work_day.end_time = sch_day.change(hour: 18, min: 0)
			@work_day.employee_id = @employee.id
			@work_day.save
		end
		
		
		#find all the work day schedules for today
		@work_days = WorkDay.all.where(start_time: [sch_day.beginning_of_day..sch_day.end_of_day])
		
		#sort the employees schedule by starting first and ending last
		@work_days = @work_days.sort_by {|wd| [wd.start_time, -wd.end_time.hour , -wd.end_time.min]}
		
		#define a list of work_task
		@work_tasks = Array.new
		
		
		#divide the work_days into slots - it goes from the start time into 2 hour slots - 2 hour is just what i say it can be easily changed		
		#----
		@work_days.each do |work_day|
			#temp is the number of hours 
			@temp = (work_day.end_time.hour - work_day.start_time.hour) + (1/60 * (work_day.end_time.min - work_day.start_time.min))
			#2 here is the time slot
			@temp = (@temp/2).floor
			#add all the work tasks
			while @temp != 0 do
				#defining the work_task it gets a certain slot - which is a slot of 2 hours, and it gets it parent - the work day
				@work_task = WorkTask.new
				@work_task.start_time = work_day.start_time.change({hour: (2*(@temp-1)) + work_day.start_time.hour})
				@work_task.end_time = work_day.end_time.change({hour: ((2*@temp) + work_day.start_time.hour)})
				@work_task.work_day_id = work_day.id
				@work_task.task_id = 0
				@work_tasks.push(@work_task)
				@temp = @temp - 1
			end
		end
		#----
		
		
		#tasks for today
		@tasks = Task.all.where(start_time: [sch_day.beginning_of_day..sch_day.end_of_day], end_time: [sch_day.beginning_of_day..sch_day.end_of_day ])
		#tasks for today or for the next days
		@rest_of_tasks = Task.all.where(start_time: [sch_day.beginning_of_day..sch_day.end_of_day], end_time: [sch_day.end_of_day..(sch_day.end_of_day.change(year: sch_day.year.to_i + 1))])
		
		@task.each do |task|
			task.status = "unassigned"
			task.save
		end
		
		@rest_of_tasks.each do |rot|
			rot.status = "unassigned"
			rot.save
		end

		
		#schedule_tasks_help(@tasks,@rest_of_tasks,@work_tasks)
		
		#@work_tasks = WorkTask.all
		
	end
		
		
end
	
end
