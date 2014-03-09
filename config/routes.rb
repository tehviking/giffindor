Giffindor::Application.routes.draw do
  devise_for :users, path_names: {sign_in: "login", sign_out: "logout"}
  resources :gif_posts
  get "home/index"
  root 'home#index'
end
