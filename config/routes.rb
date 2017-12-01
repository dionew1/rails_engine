Rails.application.routes.draw do

  namespace :api do
    namespace :v1 do
      namespace :invoices do
        get '/find_all', to: 'search#index'
        get '/find',     to: 'search#show'
        get '/random',   to: 'search#show'
      end

      resources :invoices,  only: [:index, :show] do
        resources :items, only: [:index], to: 'invoices/items#index'
        resources :invoice_items, only: [:index], to: 'invoices/invoice_items#index'
        resources :transactions, only: [:index], to: 'invoices/transactions#index'
        resources :customer, only: [:index], to: 'invoices/customer#index'
        resources :merchant, only: [:index], to: 'invoices/merchant#index'
      end

      namespace :invoice_items do
        get '/find_all', to: 'search#index'
        get '/find',     to: 'search#show'
        get '/random',   to: 'search#show'
      end

      resources :invoice_items, only: [:index, :show]

      namespace :items do
        get '/find_all',    to: 'search#index'
        get '/find',        to: 'search#show'
        get '/random',      to: 'search#show'
        get '/most_revenue',   to: 'most_revenue#index'
        get '/most_items',   to: 'most_items#index'
      end
      resources :items,  only: [:index, :show] do
        get 'best_day', to: 'best_day#index'
      end

      namespace :merchants do
        get '/find_all',             to: 'search#index'
        get '/find',                 to: 'search#show'
        get '/random',               to: 'search#show'
        get '/most_revenue',         to: 'most_revenue#index'
        get '/revenue',              to: 'revenue#index'
        get '/most_items',           to: 'item_count#index'
      end
      resources :merchants, only: [:index, :show] do
        get 'favorite_customer', to: 'favorite_customer#index'
        resources :revenue, only: [:index]
      end


      namespace :customers do
        get '/find_all', to: 'search#index'
        get '/find',     to: 'search#show'
        get '/random',   to: 'search#show'
      end
      resources :customers, only: [:index, :show]

      namespace :transactions do
        get '/find_all', to: 'search#index'
        get '/find',     to: 'search#show'
        get '/random',   to: 'search#show'
      end
      resources :transactions, only: [:index, :show]
    end
  end

end
