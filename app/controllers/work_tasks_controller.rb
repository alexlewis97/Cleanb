class WorkTasksController < ApplicationController
  before_action :set_work_task, only: [:show, :edit, :update, :destroy]

	
	def search_first(task)
		work_tasks = WorkTask.all
		work_tasks.each do |work_task|
			if work_task.start_time >= task.start_time && work_task.end_time <= task.end_time && work_task.task_id == 0 
				work_task.task_id = task.id
				return true
			end	
		end
		return false
	end
	
	def assign_tasks(tasks)
		#now we need to iterate the tasks
		counter = 0
		tasks.each do |task|
			#what we need to do here is for the task to take the first slot available
			if(search_first(task))
				counter = counter + 1 
			end
		end
		return counter
	end
	
	
	def search_first_with_save(task)
		work_tasks = WorkTask.all
		work_tasks.sort_by{|work_task| [work_task.work_day_id]}
		work_tasks.each do |work_task|
			if work_task.start_time >= task.start_time && work_task.end_time <= task.end_time && work_task.task_id == 0 
				work_task.task_id = task.id
				task.status = "assigned" 
				task.save
				work_task.save
				return true
			end	
		end
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
		counter1 = assign_tasks(sort_smallest_slot(tasks))
		counter2 = assign_tasks(sort_start_first(tasks))
		counter3 = assign_tasks(sort_end_first(tasks))
		
		
		if counter1 == counter2 && counter1 == counter3
			assign_tasks_with_save(sort_start_first(tasks).concat(sort_end_first(rest_of_tasks))) 
			return true
		end
		
		if counter1 > counter2 && counter1 > counter3
			assign_tasks_with_save(sort_smallest_slot(tasks).concat(sort_end_first(rest_of_tasks)))
			return true
		end
		
		if counter2 > counter1 && counter2 > counter3
			assign_tasks_with_save(sort_start_first(tasks).concat(sort_end_first(rest_of_tasks)))
			return true
		end
		
		if counter3 > counter1 && counter3 > counter2
			assign_tasks_with_save(sort_end_first(tasks).concat(sort_end_first(rest_of_tasks)))	
			return true
		end
	end
		
		
		
  # GET /work_tasks
  # GET /work_tasks.json
  def index
		#need to change to delete the tasks from today only
		WorkDay.delete_all
		WorkTask.delete_all
		
		Employee.all.each do |employee|  
			@work_day = WorkDay.new
			@work_day.start_time = DateTime.now.change(hour: 5, min: 0)
			@work_day.end_time = DateTime.now.change(hour: 13, min: 0)
			@work_day.employee_id = employee.id
			@work_day.save
		end
		
		
		#find all the work day schedules for today
		@work_days = WorkDay.all.where(start_time: [DateTime.now.beginning_of_day..DateTime.now.end_of_day])
		
		#sort the employees schedule by starting first and ending last
		@work_days = @work_days.sort_by {|wd| [wd.start_time, -wd.end_time.hour , -wd.end_time.min]}
		
		#divide the work_days into slots - it goes from the start time into 2 hour slots - 2 hour is just what i say it can be easily changed		
		#----
		@work_days.each do |work_day|
			@temp = (work_day.end_time.hour - work_day.start_time.hour) + (1/60 * (work_day.end_time.min - work_day.start_time.min))
			#2 here is the time slot
			@temp = (@temp/2).floor
			@counter = 1
			#add all the work tasks
			(1..@temp).each do
				#defining the work_task it gets a certain slot - which is a slot of 2 hours, and it gets it parent - the work day
				@work_task = WorkTask.new
				@work_task.start_time = work_day.start_time.change(hour: (2*(@counter-1)) + work_day.start_time.hour.to_i)
				@work_task.end_time = work_day.end_time.change(hour: ((2*@counter) + work_day.start_time.hour.to_i))
				@work_task.work_day_id = work_day.id
				@work_task.task_id = 0
				@work_task.save
				@counter = @counter + 1
			end
		end
		#----
		
		
		#tasks for today
		@tasks = Task.all.where(start_time: [DateTime.now.beginning_of_day..DateTime.now.end_of_day], end_time: [DateTime.now.beginning_of_day..DateTime.now.end_of_day ])
		@tasks_temp = Task.all.select{|task| task.status != "finished" && task.start_time < DateTime.now.beginning_of_day && task.end_time > DateTime.now.beginning_of_day && task.end_time < DateTime.now.end_of_day}
		@tasks += @tasks_temp
		#tasks for today or for the next days
		@rest_of_tasks = Task.all.where(start_time: [DateTime.now.beginning_of_day..DateTime.now.end_of_day], end_time: [DateTime.now.end_of_day..(DateTime.now.end_of_day.change(year: DateTime.now.year.to_i + 1))])
		@tasks_temp = Task.all.select{|task| task.status != "finished" && task.end_time < DateTime.now.beginning_of_day}
		@rest_of_tasks += @tasks_temp
		
		@tasks = @tasks.select{|task| task.status != "finished"}
		@rest_of_tasks = @rest_of_tasks.select{|task| task.status != "finished"}
		
		@tasks.each do |task|
			task.status = "unassigned"
			task.save
		end
		
		@rest_of_tasks.each do |task|
			task.status = "unassigned"
			task.save
		end
		
		schedule_tasks_help(@tasks,@rest_of_tasks)
		
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