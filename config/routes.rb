Rails.application.routes.draw do
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
  resources :projects do
    resources :members, only: %i(index update destroy), module: :projects
  end
  resources :estimates, only: %i(index create) do
    collection do
      post :confirm
    end
  end
  resources :bills, only: %i(index create) do
    collection do
      post :confirm
    end
  end

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

  namespace :projects do
    get 'members/edit'
  end
end
