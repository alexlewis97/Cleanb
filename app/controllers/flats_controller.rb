class FlatsController < ApplicationController
	
	def index 
		@flats = Flat.all
		counter = 1
		(1..10).each do 
			@employee = Employee.new
			@employee.name = "name" + counter.to_s
			counter = counter + 1
			@employee.save
			@work_day = WorkDay.new
			@work_day.start_time = DateTime.now.change(hour: 8, min: 0)
			@work_day.end_time = DateTime.now.change(hour: 18, min: 0)
			@work_day.employee_id = @employee.id
			@work_day.save
		end
		
	end
	
	def new
		@flat = Flat.new
	end
	
	def create
		@flat = Flat.new(flat_params)
		if @flat.save
				flash[:notice] = "Flat was successfully created"
				redirect_to flat_path(@flat)
		else
			render 'new'
		end
	end
	
	def show
		@flat = Flat.find(params[:id])
		@f_reservations = Reservation.all.where(flat_id: @flat.id)
		if !(defined?(@flat.slots))
			@flat.slots = 2 
		end
	end
	
	def edit
		@flat = Flat.find(params[:id])
	end
	
	def destroy
		@flat = Flat.find(params[:id])
		@flat.destroy
		flash[:notice] = "Flat was successfully deleted"
		redirect_to flats_path
	end
	
	def update 
		@flat = Flat.find(params[:id])
		if @flat.update(flat_params)
			flash[:notice] = "Flat was successfully updated"
			redirect_to flats_path
		else
			render 'new'
		end
	end
	
	def schedule
		WelcomeController.schedule(params[:number_of_employees].to_i)
		redirect_to root_url
	end
	
	
	private
		def flat_params
			params.require(:flat).permit(:address, :slots)
		end
end