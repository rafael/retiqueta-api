Rails.application.routes.draw do
  get 'ops/status' => 'ops#status'

  namespace :v1 do
    get 'products/search' => 'products#search'
    resources :registrations, only: :create
    resources :products,  only: [:create, :index, :destroy, :show] do
      resources :comments, only: [:create, :index, :destroy], path: 'relationships/comments', module: 'products'
    end
    resources :product_pictures, only: :create

    resources :users, only: [:show, :update] do
      resources :products, only: [:index], path: 'relationships/products', module: 'users'
      resources :followers, only: [:index], path: 'relationships/followers', module: 'users'
      resources :following, only: [:index], path: 'relationships/following', module: 'users'
      post 'follow' => 'users#follow'
      post 'unfollow' => 'users#unfollow'
      put 'upload-profile-pic' => 'users#upload_profile_pic'
    end

    resource :authenticate, only: :create do
      post 'token' => 'authenticates#refreh_token'
    end
  end
end
