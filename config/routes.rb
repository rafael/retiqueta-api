Rails.application.routes.draw do
  get 'ops/status' => 'ops#status'

  namespace :v1 do
    resources :registrations, only: :create
    resource :authenticate, only: :create
    resources :users, only: :show do
      put 'upload-profile-pic' => 'users#upload_profile_pic'
    end
  end
end
