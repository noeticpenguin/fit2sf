Rails.application.routes.draw do
  resources :rks

	get 'runkeeper/authenticate', to: 'runkeeper#authenticate'
	get 'runkeeper/callback', to: 'runkeeper#callback'
	get 'runkeeper/authorize', to: 'runkeeper#authorize'
	get 'runkeeper/', to: 'runkeeper#index'
  mount Upmin::Engine => '/admin'
  root to: 'visitors#index'
  devise_for :users
end
