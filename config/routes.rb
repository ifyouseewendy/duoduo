Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config

  resources :engineering_normal_salary_tables, controller: "engineering_salary_tables"
  resources :engineering_normal_with_tax_salary_tables, controller: "engineering_salary_tables"
  resources :engineering_big_table_salary_tables, controller: "engineering_salary_tables"
  resources :engineering_dong_fang_salary_tables, controller: "engineering_salary_tables"

  ActiveAdmin.routes(self)

  resources :contract_files, only: [:create, :destroy] do
    collection do
      get "generate_and_download"
    end
  end
end
