Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
  resource :registrations, only: [ :new, :create ]

  namespace :api do
    namespace :internal do
      resources :users, only: [ :create ] do
        collection do
          patch :update_fetchserp_api_key
          patch :update_password
        end
      end
    end
  end

  namespace :app do
    resources :domains
    resources :keywords
    resources :rankings
    resources :backlinks
    resources :search_engine_results
    resources :chat_messages, only: [ :index, :create ]
    resource :user, only: [ :edit, :update ]
    root "domains#index"
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  namespace :public, path: "/" do
    get "landing_page/index"
    get "pages", to: "seo_pages#index"
    resources :seo_pages, only: [ :show ], path: "/"
  end

  # Defines the root path route ("/")
  root "public/landing_page#index"
end
