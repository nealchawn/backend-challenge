Rails.application.routes.draw do
  # devise_for :members
  resources :members

  get 's/:unique_key' => 'members#personal_url'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
