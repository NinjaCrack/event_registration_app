Rails.application.routes.draw do
  devise_for :users
  root "events#index"

  resources :events do
    resources :registrations, only: [ :create, :edit, :update, :destroy ]
    collection do
      get :my_events
    end
  end

  namespace :admin do
    root to: "dashboard#index"

    resources :events do
      resources :registrations
      collection do
        get :search
        post :bulk
      end
    end

    resources :registrations do
      collection do
        get :search
        get :export_csv
        post :bulk
      end
    end
  end


  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
end
