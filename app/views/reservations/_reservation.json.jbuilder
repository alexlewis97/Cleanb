json.extract! reservation, :id, :check_in, :check_out, :flat_id, :created_at, :updated_at
json.url reservation_url(reservation, format: :json)
