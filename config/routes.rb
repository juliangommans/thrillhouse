ThrillHouse::Application.routes.draw do

  get '/home', to: "home#show"
  get '/battledome', to: "battledome#show"
  get '/lilcric', to: "lilcric#show"

  root to: "home#index"
  resources :character
  resources :move


end
