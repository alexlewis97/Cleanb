json.extract! work_task, :id, :work_day_id, :task_id, :finished, :created_at, :updated_at
json.url work_task_url(work_task, format: :json)
