class WorkTasksController < ApplicationController
  before_action :set_work_task, only: [:show, :edit, :update, :destroy]
	
	def next_work_task(task)
		return WorkTask.select{|w_t| w_t.work_day_id == task.work_day_id && w_t.start_time == task.end_time}.first
	end
	
	
	# this needs to be changed for the work_tasks  - Done
	def search_first(task, work_tasks)
		task_time = Flat.all.find(task.flat_id).slots
		work_tasks_for_task = Array.new
		work_tasks.each do |work_task|
			# here we need to change the condition because each work_task is only a hour, this needs to be changed into 
			# work_task > and the next work_task is also open.
			# what we can do is check if the work_tasks are open and using that we could put them together to one task
			if task.end_time.hour - work_task.start_time.hour >= task_time && work_task.task_id == 0 
				#what we are doing here is checking the next work_tasks to see if they are free
				(2..task_time).each do 
					temp_task = next_work_task(work_task)
					if temp_task && temp_task.task_id == 0
						work_tasks_for_task.push(work_task)
					else
						work_tasks_for_task.clear
						break
					end
				end
				#if we end up here that means that the work_tasks are good and can be assigned for the task
				if work_tasks_for_task.length == task_time - 1 
					work_tasks.delete(work_task)
					work_tasks.delete(work_tasks_for_task)
					return work_tasks
				end
			end
		end
		return false
	end
	
	#Changed for the dynamic slots 
	def assign_tasks(tasks)
		#now we need to iterate the tasks
		work_tasks = WorkTask.all
		counter = 0
		tasks.each do |task|
			#what we need to do here is for the task to take the first slot available
			temp_work_tasks = search_first(task,work_tasks)
			if(temp_work_tasks)
				work_tasks = temp_work_tasks
				counter = counter + 1 
			end
		end
		return counter
	end
	
	
	def search_first_with_save(task)
		task_time = Flat.all.find(task.flat_id).slots
		if task_time == nil
			@flat = Flat.all.find(task.flat_id)
			@flat.slots = 2 
			@flat.save
			task_time = 2 
		end
		work_tasks_for_task = Array.new
		work_tasks = WorkTask.all
		work_tasks.sort_by{|w| w.start_time}
		work_tasks = work_tasks.select{|w| w.task_id == 0}
		work_tasks.each do |work_task_current|
			# here I need to add more code
			#here there is a problem, first I need to check if the day is bigger
			year_dif = task.end_time.year - work_task_current.start_time.year
			month_dif = task.end_time.month - work_task_current.start_time.month
			day_dif = task.end_time.day - work_task_current.start_time.day
			hour_dif = task.end_time.hour - work_task_current.start_time.hour 
			if (hour_dif >= task_time || year_dif > 0 || month_dif > 0 || day_dif >0) && work_task_current.start_time >= task.start_time
				temp_task = work_task_current
				#what we are doing here is checking the next work_tasks to see if they are free
				(2..task_time).each do 
					temp_task = next_work_task(temp_task)
					
					if temp_task && temp_task.task_id == 0
						work_tasks_for_task.push(temp_task)
					else
						work_tasks_for_task.clear
						break
					end
					
				end
				#if we end up here that means that the work_tasks are good and can be assigned for the task
				if work_tasks_for_task.length == task_time - 1
					n_w_t = WorkTask.new
					n_w_t.start_time = work_task_current.start_time
					n_w_t.end_time = work_tasks_for_task.last.end_time
					n_w_t.work_day_id = work_task_current.work_day_id
					n_w_t.task_id = task.id
					n_w_t.save
					task.status = "assigned"
					task.save
					work_tasks_for_task.each do |w_t|
						w_t.destroy
					end
					work_task_current.destroy
					return true
				end
			end
		end
		#if not assigned - the status will be error 
		task.status = "error"
		task.save
		return false 
	end
	
	def assign_tasks_with_save(tasks)
		tasks.each do |task|
			search_first_with_save(task)
		end
	end
	
	def sort_end_first(tasks)
		tasks = tasks.sort_by{|task| [task.end_time]}
		return tasks
	end
	
	def sort_start_first(tasks)
		tasks = tasks.sort_by{|task| [task.start_time]}
		return tasks
	end
	
	def sort_smallest_slot(tasks)
		tasks = tasks.sort_by{|task| [(task.end_time.hour - task.start_time.hour) + (1/60 * (task.end_time.min - task.start_time.min)) , task.end_time , task.start_time]}
		return tasks
	end
		
	def schedule_tasks_help(tasks, rest_of_tasks)
		#for each of the tasks we should have a counter
		#counter1 = assign_tasks(sort_smallest_slot(tasks))
		#counter2 = assign_tasks(sort_start_first(tasks))
		#counter3 = assign_tasks(sort_end_first(tasks))
		
		
		#if counter1 == counter2 && counter1 == counter3
			#assign_tasks_with_save(sort_start_first(tasks).concat(sort_end_first(rest_of_tasks))) 
			#return true
		#end
		
		#if counter1 > counter2 && counter1 > counter3
			assign_tasks_with_save(sort_smallest_slot(tasks).concat(sort_end_first(rest_of_tasks)))
			#need to see how this work for the tasks that were assigned from the last day 
			#return true
		#end
		
		#if counter2 > counter1 && counter2 > counter3
			#assign_tasks_with_save(sort_start_first(tasks).concat(sort_end_first(rest_of_tasks)))
			#return true
		#end
		
		#if counter3 > counter1 && counter3 > counter2
			#assign_tasks_with_save(sort_end_first(tasks).concat(sort_end_first(rest_of_tasks)))	
			#return true
		#end
	end
		
	def clusters(sch_day)
		#make sure that each employee has one slot
		temp = 1
		Flat.all.each do |flat|
			flat.cluster = flat.temp_cluster
		end
		#this function is the function that is supposed to change the allotted tasks in order for the tasks to be in the same cluster
		main_clus_hash = {}	
		Employee.all.each do |employee|
			clus_hash = {}
			@work_day = WorkDay.all.where(employee_id: employee.id , start_time: [sch_day.beginning_of_day..sch_day.end_of_day]).first
			@work_tasks = WorkTask.all.where(work_day_id: @work_day)
			@work_tasks = @work_tasks.select{|wt| wt.task_id != 0}
			main_clus_hash[@work_day.id] = 0
			#this checks all the different clusters count
			@work_tasks.each do |wt|
				# cl is the cluster of the flat in the current task
				cl = Flat.find(Task.find(wt.task_id).flat_id).cluster
				if clus_hash[cl] == nil
					clus_hash[cl] = 1
				else
					clus_hash[cl] = clus_hash[cl] + 1
				end
			end
			
			
			max_cl = 0
			temp_max = 0
			clus_hash.each do |key, value|
				if value > temp_max
					temp_max = value
					max_cl = key
				end
			end
			
			#now we need to try and find swaps for the clusters 
			#we need to find the tasks that aren't in the cluster, and then try and change them, so if we have for example cluster number 3 and two flat so we need an array of everything not in that cluster
			#we also need to make sure that we aren't ruining other things we have already done, so if we take a cluster 3 from a cluster 3 cleaner it kind of loses the point
			#we have the hash table that basically tells us what the main cluster of the work_day is, we need a list of all the tasks from the cluster that aren't taken yet 
			
			main_clus_hash[@work_day.id] = max_cl
			
			free_work_tasks_from_cluster = WorkTask.all.where(start_time: [sch_day.beginning_of_day..sch_day.end_of_day])
			free_work_tasks_from_cluster = free_work_tasks_from_cluster.select{|wt| wt.task_id != 0}
			free_work_tasks_from_cluster = free_work_tasks_from_cluster.select{|wt| Flat.find(Task.find(wt.task_id).flat_id).cluster == max_cl && main_clus_hash[WorkDay.find(wt.work_day_id).id] != max_cl }
			
			#now we have the list of work_tasks that we can swap the tasks that we don't want from this work_day with other work_tasks
			
			#this is the list of work tasks we want to swap
			@work_tasks = @work_tasks.select{|wt| Flat.find(Task.find(wt.task_id).flat_id).cluster != max_cl}
			
			success = 0
			
			@work_tasks.each do |wt|
				#looking for swaps 
				#need to check the tasks time availability
				free_work_tasks_from_cluster.each do |fwt|
					#need to check that the time is available for the wt and the other way for fwt
					if Task.find(fwt.task_id).start_time < wt.start_time && Task.find(fwt.task_id).end_time > wt.end_time && Task.find(wt.task_id).start_time < fwt.start_time && Task.find(wt.task_id).end_time > fwt.end_time
						#we change the information for the different tasks 
						temp_id = fwt.task_id
						fwt.task_id = wt.task_id
						wt.task_id = temp_id
						fwt.save
						wt.save
						next
					end
				end	
			end
			
		end
		
		#This is an add on for the cluster function what it is supposed to do is to try and fix anything that wasn't good with the function above
		#basically what we want to do is get rid of the good allottments and make sure - we need at least 2/3 or 3/4 of the same slot 
		#take into account the clusters that are in a row 
		#we want a count of how many good and bad assignments there are, if it doesn't change after an iteration then we will finish the function
		#there needs to be a bigger loop that we will add on later
		#to be efficient maybe what we should do is have arrays so we don't need to go through all the searches
	
	end 
		
  # GET /work_tasks
  # GET /work_tasks.json
  #finished this for the next change - for the cluster - changing slots into dynamic slots
	def index()
		#need to change to delete the tasks from today only
		sch_day = params[:sch_day].to_time
		WorkTask.delete_all
		#WorkDay.select{|wt| wt.start_time.end_of_day != DateTime.now.end_of_day}.each do |wt|
			#wt.delete
		#end
		WorkDay.delete_all
		
		Employee.all.each do |employee|
			#check first that there is no workday for the employee today
			if WorkDay.select{|wd| wd.employee_id == employee.id && wd.start_time.end_of_day == sch_day.end_of_day}.first == nil
				@work_day = WorkDay.new
				# The time is according to gmt - 6 , this needs to be changed to suit the user
				@work_day.start_time = sch_day.change(hour: 4, min: 0)
				@work_day.end_time = sch_day.change(hour: 12, min: 0)
				@work_day.employee_id = employee.id
				@work_day.save
			end
		end
		
		
		#find all the work day schedules for today
		@work_days = WorkDay.all.where(start_time: [sch_day.beginning_of_day..sch_day.end_of_day])
		
		#sort the employees schedule by starting first and ending last
		@work_days = @work_days.sort_by {|wd| [wd.start_time, -wd.end_time.hour , -wd.end_time.min]}
		
		#divide the work_days into slots - it goes from the start time into 2 hour slots - 2 hour is just what i say it can be easily changed		
		#----
		@work_tasks = Array.new
		@work_days.each do |work_day|
			@temp = (work_day.end_time.hour - work_day.start_time.hour) + (1/60 * (work_day.end_time.min - work_day.start_time.min))
			#2 here is the time slot
			@temp = (@temp).floor
			@counter = 1
			#add all the work tasks
			(1..@temp).each do
				#defining the work_task it gets a certain slot - which is a slot of 2 hours, and it gets it parent - the work day
				@work_task = WorkTask.new
				@work_task.start_time = work_day.start_time.change(hour: (@counter-1) + work_day.start_time.hour.to_i)
				@work_task.end_time = work_day.end_time.change(hour: @counter + work_day.start_time.hour.to_i)
				@work_task.work_day_id = work_day.id
				@work_task.task_id = 0
				@work_tasks.push(@work_task)
				@counter = @counter + 1
			end
		end
		#----
		ActiveRecord::Base.transaction do 
			@work_tasks.each do |wt|
				wt.save
			end
		end
		
		#tasks for today
		@tasks = Task.all.where(start_time: [sch_day.beginning_of_day..sch_day.end_of_day], end_time: [sch_day.beginning_of_day..sch_day.end_of_day ])
		@tasks_temp = Task.all.select{|task| task.status != "finished" && task.start_time < sch_day.beginning_of_day && task.end_time > sch_day.beginning_of_day && task.end_time < sch_day.end_of_day}
		@tasks += @tasks_temp
		#tasks for today or for the next days
		@rest_of_tasks = Task.all.where(start_time: [sch_day.beginning_of_day..sch_day.end_of_day], end_time: [sch_day.end_of_day..(sch_day.end_of_day.change(year: sch_day.year.to_i + 1))])
		#problem here - look at the autodraw it's number 4 that isn't sent into the scheduling app
		@tasks_temp = Task.all.select{|task| task.end_time > sch_day.beginning_of_day}
		@rest_of_tasks += @tasks_temp
		
		@tasks = @tasks.select{|task| task.status != "finished"}
		@rest_of_tasks = @rest_of_tasks.select{|task| task.status != "finished"}
		
		@tasks = @tasks.uniq
		@rest_of_tasks = @rest_of_tasks.uniq
		@rest_of_tasks = @rest_of_tasks - @tasks
		
		ActiveRecord::Base.transaction do 
			@tasks.each do |task|
				task.status = "unassigned"
				task.save
			end
			@rest_of_tasks.each do |task|
				task.status = "unassigned"
				task.save
			end
		end
		
		
		schedule_tasks_help(@tasks,@rest_of_tasks)
		clusters(sch_day)
		@work_tasks = WorkTask.all
		
		redirect_to root_url
  end

	
	
	
	
	
  # GET /work_tasks/1
  # GET /work_tasks/1.json
  def show
  end

  # GET /work_tasks/new
  def new
    @work_task = WorkTask.new
  end

  # GET /work_tasks/1/edit
  def edit
  end

  # POST /work_tasks
  # POST /work_tasks.json
  def create
    @work_task = WorkTask.new(work_task_params)
		
		
		
    respond_to do |format|
			if !(WorkTask.all.select{|work_task| work_task.task_id == @work_task.task_id}.any?)
      	@work_task.save
        format.html { redirect_to @work_task, notice: 'Work task was successfully created.' }
        format.json { render :show, status: :created, location: @work_task }
      else
        format.html { render :new }
        format.json { render json: @work_task.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /work_tasks/1
  # PATCH/PUT /work_tasks/1.json
  def update
    respond_to do |format|
      if @work_task.update(work_task_params)
        format.html { redirect_to @work_task, notice: 'Work task was successfully updated.' }
        format.json { render :show, status: :ok, location: @work_task }
      else
        format.html { render :edit }
        format.json { render json: @work_task.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /work_tasks/1
  # DELETE /work_tasks/1.json
  def destroy
    @work_task.destroy
    respond_to do |format|
      format.html { redirect_to work_tasks_url, notice: 'Work task was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_work_task
      @work_task = WorkTask.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def work_task_params
      params.require(:work_task).permit(:work_day_id, :task_id, :finished)
    end
end



# what now - we need to now give the option of viewing all the different tasks etc.
# The first page that we need to have is the ability to view all the tasks from today
# 