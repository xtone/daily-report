Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'reports#index'

  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }

  devise_scope :user do
    get 'users/sign_out', to: 'users/sessions#destroy'
    resources :users
  end

  resources :reports
  resources :projects

  namespace :settings do
    resources :projects
  end

  scope :admin do
    root to: 'admin#index', as: :admin_root
  end
  namespace :admin do
    resources :csvs, only: [:index]
  end
end
