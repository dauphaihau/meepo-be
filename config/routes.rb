Rails.application.routes.draw do
  mount ActionCable.server => '/cable'

  devise_for :users,
             controllers: {
               sessions: 'users/sessions',
               registrations: 'users/registrations',
             }
  resources :users
  get '/me', to: 'users#me'
  post '/users/:id/follow', to: "users#follow", as: "follow_user"
  post '/users/:id/unfollow', to: "users#unfollow", as: "unfollow_user"

  resources :posts
  resources :hashtags
  resources :likes, only: [:create]

  resources :search, only: [:index]

  resources :rooms, only: [:show]
  resources :messages, only: [:create, :index]
end
