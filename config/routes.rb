Rails.application.routes.draw do
  get 'ops/status' => 'ops#status'

  namespace :v1 do
    resources :registrations, only: :create
    resource :authenticate, only: :create do
      post 'token' => 'authenticates#refreh_token'
    end
    resources :users, only: :show
  end
end
