Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "pages#home"

  get "/about", to: "pages#about"
  get "/listen", to: "pages#listen"

  resources :updates, only: [ :index ], param: :slug
  get "/updates/:slug", to: "updates#show", as: :update

  get "/articles/:slug", to: "articles#show", as: :article

  post "/track", to: "analytics_events#create"

  get "/sitemap.xml", to: "sitemaps#show", defaults: { format: :xml }

  match "*unmatched", to: "errors#not_found", via: :all
end
