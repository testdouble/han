Rails.application.routes.draw do
  get "/users", to: "users#show"
  post "/login", to: "sessions#create"
end
