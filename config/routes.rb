Rails.application.routes.draw do
  mount ActionCable.server => '/cable'

  devise_for :users,
             controllers: {
               sessions: 'users/sessions',
               registrations: 'users/registrations',
             }

  resources :posts
  post '/posts/likes', to: 'likes#create'
  resources :users

  get '/member-data', to: 'members#show'
end
