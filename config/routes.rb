Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  resources :contract_files, only: [:create, :destroy] do
    collection do
      get "generate_and_download"
    end
  end
end
