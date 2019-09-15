class ReservationsController < ApplicationController
  before_action :set_reservation, only: [:show, :edit, :update, :destroy]

  # GET /reservations
  # GET /reservations.json
  def index
    @reservations = Reservation.all
  end

  # GET /reservations/1
  # GET /reservations/1.json
  def show
  end

  # GET /reservations/new
  def new
    @reservation = Reservation.new
  end

  # GET /reservations/1/edit
  def edit
  end

  # POST /reservations
  # POST /reservations.json
  def create
    @reservation = Reservation.new(reservation_params)
		# we need to check that there are no reservations under the flat currently
		# so we need to check by the reservations that have the same flat_id 
		# we need to check that the flat exists - that is already done because of the belongs_to that we have in the model
		
		@reservations = Reservation.select {|reserve| reserve.flat_id == @reservation.flat_id}
		@reservations.each do |reserve|
			#if @reservation.check_in > reserve.check_in && @reservation.check_in < reserve.check_out || @reservation.check_out > reserve.check_out && @reservation.check_out < reserve.check_out 
				#render 'new'
			#end
		end
		
    respond_to do |format|
      if @reservation.save
        format.html { redirect_to @reservation, notice: 'Reservation was successfully created.' }
        format.json { render :show, status: :created, location: @reservation }
      else
        format.html { render :new }
        format.json { render json: @reservation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /reservations/1
  # PATCH/PUT /reservations/1.json
  def update
    respond_to do |format|
      if @reservation.update(reservation_params)
				#find the task that was created by this reservation and update it 
				#this needs to be done twice, the first for the task for before check in and one for after check out 
				@task = Task.find{|task| task.flat_id == @reservation.flat_id && task.end_time.end_of_day == @reservation.check_in.end_of_day}
				if(@task)
					@task.end_time = @reservation.check_in
					@task.save
				end
				@task = Task.find{|task| task.flat_id == @reservation.flat_id && task.start_time.end_of_day == @reservation.check_out.end_of_day}
				if(@task)
					@task.start_time = @reservation.check_out
					@task.save
				end
        format.html { redirect_to @reservation, notice: 'Reservation was successfully updated.' }
        format.json { render :show, status: :ok, location: @reservation }
      else
        format.html { render :edit }
        format.json { render json: @reservation.errors, status: :unprocessable_entity }
      end
    end
  end

	def import_reservations_file
		
	end
	
  # DELETE /reservations/1
  # DELETE /reservations/1.json
  def destroy
    @reservation.destroy
    respond_to do |format|
      format.html { redirect_to reservations_url, notice: 'Reservation was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
	
	def import
		Reservation.import_reservation(params[:file])
		redirect_to tasks_updating_path notice: "Reservations imported"
	end
	
	

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_reservation
      @reservation = Reservation.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def reservation_params
      params.require(:reservation).permit(:check_in, :check_out, :flat_id)
    end
end
