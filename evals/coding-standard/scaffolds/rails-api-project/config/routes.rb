Rails.application.routes.draw do
  get "/pi", to: "pi#calculate"
  get "/fibonacci", to: "fibonacci#calculate"
end
