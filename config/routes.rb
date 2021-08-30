Rails.application.routes.draw do
  # devise_for :members
  resources :members do
    get 'experts' => "members#experts"
    resources :friendships, only: [:create]
  end

  get 's/:unique_key' => 'members#personal_url'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
