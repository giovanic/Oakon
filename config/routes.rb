Rails.application.routes.draw do
  devise_for :admin_users
  ActiveAdmin.routes(self)

  namespace :admin do
    get "dashboard", to: "dashboard#index"

    resources :categories
    resources :products do
      resources :images, only: :destroy, controller: "product_images"
    end
    resources :orders, only: %i[index show] do
      member do
        patch :cancel
      end
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  scope module: "storefront" do
    root to: "home#index"
    get "produtos/:slug", to: "products#show", as: :product
    get "categorias/:slug", to: "categories#show", as: :category
    resource :purchase, only: :show, path: "carrinho"
    resources :purchase_items, only: %i[create update destroy], path: "carrinho/itens"
    resource :checkout, only: %i[new create], path: "finalizar-pedido"
    resources :orders, only: :show, path: "pedidos"
  end
end
