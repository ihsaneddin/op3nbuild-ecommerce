Hadean::Application.routes.draw do

  resources :image_groups
  mount Resque::Server.new, at: "/resque"

  namespace(:admin){ namespace(:customer_service){ resources :comments } }

  resources :user_sessions, only: [:new, :create, :destroy]

  get 'admin'       => 'admin/overviews#index'
  get 'login'       => 'user_sessions#new'
  get 'logout'      => 'user_sessions#destroy'
  delete 'logout'   => 'user_sessions#destroy'
  get 'signup'      => 'customer/registrations#new'
  get 'admin/merchandise' => 'admin/merchandise/summary#index'

  resource  :about,       only: [:show]
  resources :products,    only: [:index]
  resources :states,      only: [:index]
  resources :terms,       only: [:index]
  resource  :unsubscribe, only: :show
  resources :wish_items,  only: [:index, :destroy]

  resources :contractors, only: [:index, :show]

  root :to => "welcome#index"
  #root :to => "market_places/home#index"

  namespace :customer do
    resources :registrations,   only: [:index, :new, :create]
    resource  :password_reset,  only: [:new, :create, :edit, :update]
    resource  :activation,      only: [:show]
  end

  namespace :myaccount do
    concern :commentable do
      resources :comments, only: [:index, :new, :create]
    end
    resources :notifications, only: [:index, :update]
    resources :orders,        only: [:index, :show]
    resources :refunds,       only: [:index, :show, :new, :create], concerns: [:commentable] do 
      member do 
        put :cancel
      end
    end
    resources :addresses
    resources :credit_cards
    resources :referrals,     only: [:index, :create, :update]
    resource  :store_credit,  only: [:show]
    resource  :overview,      only: [:show, :edit, :update]
  end

  namespace :shopping do
    resources  :addresses do
      member do
        put :select_address
      end
    end

    resources  :billing_addresses do
      member do
        put :select_address
      end
    end

    resources  :cart_items, except: [:create, :new] do
      member do
        put :move_to
      end
    end
    resource  :coupon, only: [:show, :create]

    resources  :orders do
      member do
        get :checkout
        get :confirmation
      end
    end
    resources  :shipping_methods
  end

  namespace :admin do

    resources :sessions, only: [:new, :create, :destroy]
    resources :balances, only: [:index]
    namespace :balances do
      concern :commentable do
        resources :comments, only: [:index, :new, :create]
      end
      resources :credits, only: [:index, :show, :create], concerns: [:commentable] do 
        member do 
          put :reject
          put :pay
        end
      end
      namespace :requests do
        resources :withdraws, except: [:edit, :update, :destroy], concerns: [:commentable] do 
          member do 
            put :approve
            put :reject
            put :cancel
          end
        end
        resources :refunds, except: [:edit, :update, :destroy], concerns: [:commentable] do 
          member do 
            put :approve
            put :reject
            put :cancel
          end
        end
      end
    end
    

    namespace :customer_service do
      resources :users do
        resources :comments
      end
    end
    resources :users
    namespace :user_datas do

      resources :referrals do
        member do
          post :apply
        end
      end

      resources :users do
        resource :store_credits, only: [:show, :edit, :update]
        resources :addresses
      end
    end
    resources :overviews, only: [:index]

    get "help" => "help#index"

    namespace :reports do
      resource :overview, only: [:show]
      resources :graphs
      resources :weekly_charts, only: [:index]
    end
    namespace :rma do
      resources  :orders do
        resources  :return_authorizations do
          member do
            put :complete
          end
        end
      end
      #resources  :shipments
    end

    namespace :history do
      resources  :orders, only: [:index, :show] do
        resources  :addresses, only: [:index, :show, :edit, :update, :new, :create]
      end
    end

    namespace :fulfillment do
      resources  :orders do
        member do
          put :create_shipment
        end
        resources  :comments
      end

      namespace :partial do
        resources  :orders do
          resources :shipments, only: [ :create, :new, :update ]
        end
      end

      resources  :shipments do
        member do
          put :ship
        end
        resources  :addresses , only: [:edit, :update]# This is for editing the shipment address
      end
    end
    namespace :shopping do
      resources :carts
      resources :products
      resources :users
      namespace :checkout do
        resources :billing_addresses, only: [:index, :update, :new, :create, :select_address] do
          member do
            put :select_address
          end
        end
        resources :credit_cards
        resource  :order, only: [:show, :update, :start_checkout_process] do
          member do
            post :start_checkout_process
          end
        end
        resources :shipping_addresses, only: [:index, :update, :new, :create, :select_address] do
          member do
            put :select_address
          end
        end
        resources :shipping_methods, only: [:index, :update]
      end
    end
    namespace :config do
      resources :accounts
      resources :countries, only: [:index, :edit, :update, :destroy] do
        member do
          put :activate
        end
      end
      resources :overviews
      resources :shipping_categories
      resources :shipping_rates
      resources :shipping_methods
      resources :shipping_zones
      resources :tax_rates
      resources :tax_categories
    end

    namespace :generic do
      resources :coupons
      resources :deals
      resources :sales
    end
    namespace :inventory do
      resources :suppliers
      resources :overviews
      resources :purchase_orders
      resources :receivings
      resources :adjustments
    end

    namespace :merchandise do
      namespace :images do
        resources :products
      end
      resources :image_groups
      resources :properties
      resources :prototypes
      resources :brands
      resources :product_types
      resources :prototype_properties

      namespace :changes do
        resources :products do
          resource :property,          only: [:edit, :update]
        end
      end

      namespace :wizards do
        resources :brands,              only: [:index, :create, :update]
        resources :products,            only: [:new, :create]
        resources :properties,          only: [:index, :create, :update]
        resources :prototypes,          only: [:update]
        resources :tax_categories,      only: [:index, :create, :update]
        resources :shipping_categories, only: [:index, :create, :update]
        resources :product_types,       only: [:index, :create, :update]
      end

      namespace :multi do
        resources :products do
          resource :variant,      only: [:edit, :update]
        end
      end
      resources :products do
        member do
          get :add_properties
          put :activate
        end
        resources :variants
      end
      namespace :products do
        resources :descriptions, only: [:edit, :update]
      end
    end
    namespace :document do
      resources :invoices
    end

    namespace :wizards do 
      namespace :products do
        resources :items, only: [:new, :create, :edit, :update]
      end
    end

  end #of admin

  #Openbuild
  #API Routes
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :registrations, only: [:create]
      resources :sessions, only: [:create, :destroy]
      post 'users/activate' => 'users#activate'
      post 'users/deactivate' => 'users#deactivate'
      post 'users/upgrade' => 'users#upgrade'
      post 'users/downgrade' => 'users#downgrade'
      #post 'users/remove_trial' => 'users#remove_trial'
      #post 'users/cancel_trial' => 'users#cancel_trial'
      post 'users/activate_account' => 'users#activate_account'
      post 'users/deactivate_account' => 'users#deactivate_account'
      put 'users' => 'users#update'
      
      resources :products

      namespace :rollback do 
        post 'users/trial' => 'users#trial'
      end

    end
  end

  namespace :openbuild do
    resources :sessions, only: [:create]
    delete 'session' => 'sessions#destroy'
  end

  #Marketplace routes
  scope ':contractor' do
    namespace :market_places do
      resources :products, only: [:index, :create, :show]

      namespace :shopping do
        resources  :addresses do
          member do
            put :select_address
          end
        end

        resources  :billing_addresses do
          member do
            put :select_address
          end
        end

        resources  :cart_items do
          member do
            put :move_to
          end
        end
        resource  :coupon, only: [:show, :create]

        resources  :orders do
          member do
            get :checkout
            get :confirmation
          end
        end
        resources  :shipping_methods
      end

    end
  end

end
