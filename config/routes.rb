Rails.application.routes.draw do
  get 'ops/status' => 'ops#status'
  post 'e22e9a38-cd10-4132-b2d3-a845b0aa0539' => 'ops#ionic_webhook'

  namespace :v1 do
    get 'products/search' => 'products#search'
    resources :registrations, only: :create
    resources :products,  only: [:create, :index, :destroy, :show] do
      resources :comments, only: [:create, :index, :destroy], path: 'relationships/comments', module: 'products'
      resources :likes, only: [:index], path: 'relationships/likes', module: 'products'
      post 'like' => 'products#like'
      post 'unlike' => 'products#unlike'
    end
    resources :product_pictures, only: :create

    resources :users, only: [:show, :update] do
      resources :products, only: [:index], path: 'relationships/products', module: 'users'
      resources :followers, only: [:index], path: 'relationships/followers', module: 'users'
      resources :following, only: [:index], path: 'relationships/following', module: 'users'
      resources :push_tokens, only: [:create], path: 'relationships/push_tokens', module: 'users'
      post 'follow' => 'users#follow'
      post 'unfollow' => 'users#unfollow'
      put 'upload-profile-pic' => 'users#upload_profile_pic'
    end

    resources :orders, only: :create

    resource :authenticate, only: :create do
      post 'token' => 'authenticates#refreh_token'
    end

    post 'send_password_reset' => 'password_actions#send_reset'
    post 'reset_password' => 'password_actions#reset'
  end
end
