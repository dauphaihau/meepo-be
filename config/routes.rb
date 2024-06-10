Rails.application.routes.draw do
  mount ActionCable.server => '/cable'

  devise_for :users,
             controllers: {
               sessions: 'users/sessions',
               registrations: 'users/registrations',
               # password_resets: 'users/password_resets',
             }
  resources :users
  get '/me', to: 'users#me'
  post '/users/:id/follow', to: 'users#follow', as: 'follow_user'
  post '/users/:id/unfollow', to: 'users#unfollow', as: 'unfollow_user'
  post '/users/password/reset', to: 'password_resets#create'
  patch '/users/password/reset', to: 'password_resets#edit'
  put '/users/password/reset', to: 'password_resets#update'

  resources :posts
  resources :hashtags
  resources :likes, only: [:create]

  resources :search, only: [:index]

  resources :rooms, only: [:show]
  # resources :messages, only: %i[create index]
  get '/messages', to: 'messages#index'
  get '/messages/last', to: 'messages#last_messages'
  post '/messages', to: 'messages#create'
  # resources :messages, only: [:create, :index]
end
