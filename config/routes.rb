require 'sidekiq/web'

Rails.application.routes.draw do
  concern :notifiable do
    resources :notifications, only: [:index, :show] do
      patch :mark_as_read, on: :member
      get :unreads_count, on: :collection
    end
  end

  use_doorkeeper

  devise_for :admins,
    module: 'administrator',
    path: 'administrator',
    skip: %i[sessions registrations] # we're using doorkeeper with tokens

  devise_for :users,
    module: 'coop',
    path: 'cooperative', # removing /users from path
    skip: %i[sessions registrations] # we're using doorkeeper with tokens

  devise_for :suppliers,
    module: 'supp',
    path: 'supplier', # removing /supplier from path
    skip: %i[sessions registrations] # we're using doorkeeper with tokens

  resource :echo, only: :show, controller: :echo
  resource :profile, only: :show

  namespace :supp, path: 'supplier', as: 'supplier' do
    concerns :notifiable

    resource :device_tokens, only: :create
    resource :dashboard, only: :show
    resource :map, only: :show

    resources :contracts, only: [:index, :show] do
      resource :refused, module: 'contracts', only: [:update]
      resource :signs, module: 'contracts', only: [:update]
    end

    resources :biddings, only: [:index, :show] do
      namespace :invites, module: 'biddings' do
        resources :open, module: 'invites', only: [:create]
        resources :closed, module: 'invites', only: [:create]
      end

      resources :proposal_imports, module: 'biddings', only: [:show, :create]
      get :download

      resources :lots, module: 'biddings', only: [:index, :show] do
        resources :lot_proposals, module: 'lots', only: [:index, :show, :create, :update, :destroy]
        resources :lot_proposal_imports, module: 'lots', only: [:show, :create]
        get :download
      end

      resources :proposals, module: 'biddings', only: [:index, :show, :create, :update, :destroy] do
        patch :finish, on: :member
      end
    end

    patch 'profile', to: 'suppliers#profile'
  end

  namespace :coop, path: 'cooperative', as: 'cooperative' do
    concerns :notifiable

    resource :device_tokens, only: :create
    resource :dashboard, only: :show
    resource :map, only: :show

    resources :contracts, only: [:index, :show] do
      resources :items, module: 'contract', only: [:index]
      resource :completed, module: 'contract', only: [:update]
      resource :partial_execution, module: 'contract', only: [:update]
      namespace :total_inexecution, module: 'contract' do
        resource :clone_bidding, module: 'total_inexecution', only: [:update]
        resource :proposal, module: 'total_inexecution', only: [:update]
      end
      namespace :refused, module: 'contract' do
        resource :clone_bidding, module: 'refused', only: [:update]
        resource :proposal, module: 'refused', only: [:update]
      end
    end

    resources :classifications, only: :index

    resources :biddings do
      resources :additives, module: 'biddings', only: :create

      resources :invites, module: 'biddings', only: [:index] do
        resource :approves, module: 'invites', only: [:update]
        resource :reproves, module: 'invites', only: [:update]
      end
      resource :failure, module: 'biddings', only: [:update]
      resource :finish, module: 'biddings', only: [:update]
      resource :refinish, module: 'biddings', only: [:update]
      resources :lots, module: 'biddings' do
        resources :lot_proposals, module: 'lots', only: [:index, :show]
      end

      resource :waiting, module: 'biddings', only: [:update]
      resources :cancellation_requests, module: 'biddings', only: [:create]
      resources :proposals, module: 'biddings', only: [:index, :show]
    end

    resources :covenants, only: [:index, :show] do
      resources :groups, module: 'covenants', only: [:index, :show]
      resources :group_items, module: 'covenants', only: :index
    end

    resources :proposals, only: [] do
      resource :accept, module: 'proposals', only: [:update]
      resource :refuse, module: 'proposals', only: [:update]
    end

    resources :providers, only: [:index, :show]

    resources :lot_proposals, only: [] do
      resource :accept, module: 'lot_proposals', only: [:update]
      resource :refuse, module: 'lot_proposals', only: [:update]
    end

    patch 'profile', to: 'users#profile'
  end

  namespace :administrator do
    concerns :notifiable

    resources :units, only: :index
    resources :contracts, only: [:index, :show]


    namespace :reports do
      resources :biddings, only: :index
      resources :contracts, only: :index
    end

    resources :reports, only: [:create, :index, :show] do
      resource :download, module: 'reports', only: :show
    end

    resource :dashboard, only: :show
    resources :admins, except: [:new, :edit]

    patch 'profile', to: 'admins#profile'

    resources :biddings, only: [:index, :show] do
      resources :cancellation_requests, module: 'biddings', only: [] do
        resource :approve, module: 'cancellation_requests', only: [:update]
        resource :reprove, module: 'cancellation_requests', only: [:update]
      end

      resources :contracts, module: 'biddings', only: [:index, :show]
    end

    resources :covenants, except: [:new, :edit] do
      resources :groups, module: 'covenants', only: [:show, :create, :update, :destroy]

      resources :biddings, module: 'covenants', only: [:index, :show] do
        resources :proposals, module: 'biddings', only: [:index]

        resources :lots, only: [:index], module: 'biddings' do
          resources :lot_proposals, module: 'lots', only: [:index]
        end
      end
    end

    resources :cooperatives, except: [:new, :edit]

    resources :configurations, only: [:index, :update] do
      post :import, on: :member
    end

    resources :lot_proposals, only: [] do
      resource :accept, module: 'lot_proposals', only: [:update]
      resource :refuse, module: 'lot_proposals', only: [:update]
      resource :fail, module: 'lot_proposals', only: [:update]
    end

    resources :proposals, only: [] do
      resource :accept, module: 'proposals', only: [:update]
      resource :refuse, module: 'proposals', only: [:update]
      resource :fail, module: 'proposals', only: [:update]
    end

    resources :biddings, only: [] do
      resource :fail, module: 'biddings', only: [:update]
      resource :ongoing, module: 'biddings', only: [:update]
      resource :approve, module: 'biddings', only: [:update]
      resource :reprove, module: 'biddings', only: [:update]
      resource :review, module: 'biddings', only: [:update]
      resource :force_review, module: 'biddings', only: [:update]
    end

    resources :providers, except: [:new, :edit] do
      post :block
      post :unblock
    end

    resources :items, except: [:new, :edit]
    resources :users, except: [:new, :edit]
    resources :suppliers, except: [:new, :edit]
  end

  resources :providers, only: [:create, :update]

  namespace :search do
    resources :admins, only: :index
    resources :cities, only: :index
    resources :cooperatives, only: :index
    resources :classifications, only: :index
    resources :items, only: :index
    resources :providers, only: :index
    resources :users, only: :index
    resources :roles, only: :index
    namespace :register do
      resources :providers, only: :index
    end
  end
end
