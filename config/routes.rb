Rails.application.routes.draw do
  get 'ops/status' => 'ops#status'

  namespace :v1 do
    resources :registrations, only: :create
    resources :product_pictures, only: :create

    resources :users, only: [:show, :update] do
      put 'upload-profile-pic' => 'users#upload_profile_pic'
    end

    resource :authenticate, only: :create do
      post 'token' => 'authenticates#refreh_token'
    end
  end
end
