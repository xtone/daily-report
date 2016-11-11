Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'reports#index'

  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }

  devise_scope :user do
    get 'users/sign_out', to: 'users/sessions#destroy'
    resources :users, only: [:index, :show]
  end

  resources :reports
  resources :projects

  scope :csvs do
    get :reports, to: 'reports#csv'
    get :projects, to: 'projects#csv'
    get :users, to: 'users#csv'
  end
end
