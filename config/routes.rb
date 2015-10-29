ThrillHouse::Application.routes.draw do

  get '/home', to: "home#show"
  get '/battledome', to: "battledome#show"
  get '/lilcric', to: "lilcric#show"
  get '/lilrpg', to: "lilrpg#show"
  get '/lilrpg/mapedit', to: "lilrpg#mapedit"

  root to: "home#index"
  resources :lil_rpg_map_editor
  resources :character
  resources :move


end
