Rails.application.routes.draw do
  resources :games, only: [:new, :create, :show] do
    member do
      post :guess
    end
  end
  
  root 'games#new'
end