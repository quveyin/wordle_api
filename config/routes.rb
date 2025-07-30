Rails.application.routes.draw do
  resources :games, only: [:new, :create]
  
  # Token-based game routes
  get '/game/:token', to: 'games#show', as: 'game_token'
  post '/game/:token/guess', to: 'games#guess', as: 'game_token_guess'
  
  root 'games#new'
end