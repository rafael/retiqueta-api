Rails.application.routes.draw do
  get 'ops/status' => 'ops#status'

  namespace :v1 do
    resource :registrations, only: :create
    resource :authenticate, only: :create
  end
end
