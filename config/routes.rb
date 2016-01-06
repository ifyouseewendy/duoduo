Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config

  resources :engineering_normal_salary_tables, controller: "engineering_salary_tables"
  resources :engineering_normal_with_tax_salary_tables, controller: "engineering_salary_tables"
  resources :engineering_big_table_salary_tables, controller: "engineering_salary_tables"
  resources :engineering_dong_fang_salary_tables, controller: "engineering_salary_tables"

  resources :engineering_normal_with_tax_salary_items do
    collection do
      post 'import_do'
      get 'import_new'
      get 'import_demo'
    end
  end
  resources :engineering_normal_salary_items do
    collection do
      post 'import_do'
      get 'import_new'
      get 'import_demo'
    end
  end

  ActiveAdmin.routes(self)

  resources :big_contracts, only: [:create, :destroy] do
    member do
      post 'activate'
      post 'deactivate'
    end
  end

  resources :contract_files, only: [:create, :destroy] do
    collection do
      get "generate_and_download"
    end
  end
  resources :contract_templates, only: [:create, :destroy] do
    collection do
      get "generate_and_download"
    end
  end
  resources :engineering_contract_files, only: [:create, :destroy] do
    collection do
      post "generate_and_download"
    end
  end

end
