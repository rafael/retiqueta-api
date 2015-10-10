Rails.application.routes.draw do
  get 'ops/status' => 'ops#status'
  resource :authentication, only: :create

  namespace :v1 do
    resource :registrations, only: :create
  end
end
