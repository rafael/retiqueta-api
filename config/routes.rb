Rails.application.routes.draw do
  get 'ops/status' => 'ops#status'
  namespace :v1 do
    resource :registrations, only: :create
  end
end
