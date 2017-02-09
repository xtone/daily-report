Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'reports#index'

  devise_for :users, controllers: {
    sessions: 'users/sessions'
  }

  devise_scope :user do
    get 'users/sign_out', to: 'users/sessions#destroy'
    resources :users do
      member do
        patch 'revive'
      end
    end
  end

  resources :reports do
    collection do
      resource :summary, only: %i(show), module: :reports
      resource :unsubmitted, only: %i(show), module: :reports
    end
  end
  resources :projects

  namespace :settings do
    resources :projects, only: %i(index update destroy)
    resource :password, only: %i(show update)
  end

  scope :admin do
    root to: 'admin#index', as: :admin_root
  end

  namespace :admin do
    resources :csvs, only: %i(index)
  end
end