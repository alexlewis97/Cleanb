Rails.application.routes.draw do
  resources :work_tasks
  resources :work_days
  resources :employees
	
	resources :reservations do 
  	collection {post :import}
	end
	
		
	# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
	root 'welcome#home' 
	get 'welcome/des', to: 'welcome#des'
	get '/schedule', to: 'welcome#schedule'
	get 'welcome/scheduler', to: 'welcome#scheduler'
	get 'welcome/employee', to: 'welcome#employee'
	get 'welcome/change_status_to_finish', to: 'welcome#change_status_to_finish'
	get 'welcome/change_status_to_finish_via_employee', to: 'welcome#change_status_to_finish_via_employee'
	get 'tasks/updating', to: 'tasks#update_tasks'
	get 'welcome/import_reservations_file', to: 'welcome#import_reservations_file'
	get 'welcome/tomorrow', to: 'welcome#tomorrow_task'
	get 'welcome/finished', to: 'welcome#change_all_to_finish'
	
	
	# The functions for adding the different flats
	resources :flats do
		collection {post :schedule}
	end
	
	# The functions for adding the different tasks
	resources :tasks do
	end
	
	get'tasks/change_status_to_finish_via_home', to: 'tasks#change_status_to_finish_via_home'
	
end
