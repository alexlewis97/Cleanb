class Reservation < ApplicationRecord
	belongs_to :flat
	
	def self.import_reservation(file)
		new_reservations = Array.new
		spreadsheet = open_spreadsheet(file)
		header = spreadsheet.row(6)
		
		(4..(spreadsheet.last_row/2 - 9)).each do |i|
			reser = Reservation.new
			
			#add check in
			resdate = spreadsheet.cell((i*2),4)	
			reser.check_in = self.format_todate(resdate)
		
			#add check out 
			resdate = spreadsheet.cell((i*2),5)
			reser.check_out = self.format_todate(resdate)
			
			#add flat_id
			flatname = spreadsheet.cell((i*2),3)
			#need to check if the flat exists first
			if !(Flat.all.find{|f| f.address == flatname})
				flat = Flat.new(address: flatname)
				flat.save
			end
			reser.flat_id = Flat.all.select{|f| f.address == flatname}.first.id
			new_reservations.push(reser)
		end
		
		
		r_reservations = Array.new
		# check if the new_reservation is in the old reservation if so add the old reservation to the new list of reservations, otherwise add the new reservation to the list of reservations
		new_reservations.each do |n_r|
			reservation = Reservation.all.select{|reser| reser.flat_id == n_r.flat_id && reser.check_in.end_of_day == n_r.check_in.end_of_day}.first
			if reservation != nil
				o_r = Reservation.new
				o_r.flat_id = reservation.flat_id
				o_r.check_in = reservation.check_in
				o_r.check_out = reservation.check_out
				r_reservations.push(o_r)
			else
				r_reservations.push(n_r) 
			end
		end
		
		Reservation.delete_all
		
		ActiveRecord::Base.transaction do 
			r_reservations.each do |reser|
				reser.save
			end
		end
		

	end
	
	def self.open_spreadsheet(file)
		#case file.extname(file.original_filename)
		#when ".xls"
		Roo::Excel.new(file.path)
		#else
		#raise "Unknown file type: #{file.original_filename}"
		#end
	end
	

	def self.format_todate(resdate)		
		
		resday = resdate.split[2..3]
		resdate = resdate.split[0]
		r_year = resdate.split("-")[2]
		r_day = resdate.split("-")[1]
		#need to convert the date
		r_month = self.convert_date(resdate.split("-")[0])
		if resday[1] == "am"
			r_hour = resday[0].split(":")[0].to_i
		end
		if resday[1] == "pm"
			r_hour= resday[0].split(":")[0].to_i + 12
		end
		r_min = resday.split[0].split(":")[1]
		return DateTime.new(r_year.to_i,r_month.to_i,r_day.to_i,r_hour,r_min.to_i)
	end

	def self.convert_date(stringdate)
		case stringdate
			when "Jan" 		
				1
			when "Feb"
				2
			when "Mar"
				3 
			when "Apr" 
				4
			when "May" 
				5
			when "Jun" 
				6
			when "Jul" 
				7
			when "Aug" 
				8
			when "Sep" 	
				9
			when "Oct"  
				10
			when "Nov"  
				11
			when "Dec"  	
				12
		else 0
		end
	end
end
