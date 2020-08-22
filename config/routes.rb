Rails.application.routes.draw do
  namespace :api, constraints: { format: 'json' } do
    resources :users do
      resources :medical_recommendations, path: "med_recs"
      resources :identifications
    end
  end
end
