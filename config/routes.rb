Rails.application.routes.draw do
  get 'ops/status' => 'ops#status'

  namespace :v1 do
    get 'products/search' => 'products#search'
    resources :registrations, only: :create
    resources :products,  only: :create
    resources :product_pictures, only: :create do
    end

    resources :users, only: [:show, :update] do
      resources :products, only: [:index], path: 'relationships/products', module: 'users'
      put 'upload-profile-pic' => 'users#upload_profile_pic'
    end

    resource :authenticate, only: :create do
      post 'token' => 'authenticates#refreh_token'
    end
  end
end
