Rails.application.routes.draw do
  post 'auth/login', to: 'authentication#authenticate'
  namespace :api, constraints: { format: 'json' } do
    post 'signup', to: 'users#create'
    resources :users do
      resources :medical_recommendations, path: 'med_recs', except: [:index]
      resources :identifications, except: [:index]
    end
  end
end
