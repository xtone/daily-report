Rails.application.routes.draw do
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
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
