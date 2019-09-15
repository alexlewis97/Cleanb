json.extract! employee, :id, :type_of_work, :created_at, :updated_at
json.url employee_url(employee, format: :json)
