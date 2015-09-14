Rails.application.routes.draw do
  get 'ops/status' => 'ops#status'
  namespace :v1 do
  end
end
