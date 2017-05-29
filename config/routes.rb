Rails.application.routes.draw do

  devise_for :users,
             path: 'saisie', path_names: {sign_in: 'connexion', sign_out: 'deconnexion',
                                             password: 'reinitialiser', confirmation: 'verification',
                                             registration: 'enregistrement'}
  devise_for :moderators,
             path: 'validation', path_names: {sign_in: 'connexion', sign_out: 'deconnexion',
                                                           password: 'reinitialiser', confirmation: 'verification',
                                                           registration: 'enregistrement'}

  devise_scope :user do
    get '/oauth/auth/apidae/callback' => 'users/omniauth_callbacks#apidae'
  end

  devise_scope :moderator do
    get '/oauth/auth/apidae_admin/callback' => 'moderators/omniauth_callbacks#apidae'
  end

  authenticated :user do
    get '/', to: 'user/dashboard#index', as: 'user_dashboard'
  end

  authenticated :moderator do
    get '/', to: 'moderator/dashboard#index', as: 'moderator_dashboard'
  end

  concern :programs_routes do
    resources :programs, path: 'programmations' do
      resources :program_items, path: 'offres' do
        get 'confirm', on: :member, path: 'confirmation'
        post 'duplicate', on: :member, as: 'duplicate'
        patch 'reorder', on: :member, as: 'reorder'
        get 'select_program', on: :member, as: 'select'
        patch 'save_program', on: :member, as: 'save'
        patch 'set_opening', on: :collection, as: 'opening'
        get 'update_form', on: :collection, as: 'update_form'
        get 'site_desc', on: :collection, as: 'site_desc'
      end
    end
    resources :program_items, path: 'offres', as: 'items', only: [:index] do
      get 'account', on: :collection, path: 'compte'
      get 'entity', on: :collection, path: 'structure'
    end
  end

  namespace :user, path: 'saisie' do
    scope(path_names: {new: 'creer', edit: 'modifier'}) do
      concerns :programs_routes
      resource :user, controller: 'account', path: 'compte', as: 'account', only: [:edit, :update] do
        get 'search_entity', on: :collection, as: 'search_entity'
        get 'towns', on: :collection, as: 'towns'
        get 'communication', on: :collection
        patch 'update_communication', on: :collection, as: 'com_poll'
      end
      get 'support', to: 'dashboard#support', path: 'support'
    end
  end

  namespace :moderator, path: 'validation' do
    scope(path_names: {new: 'creer', edit: 'modifier'}) do
      concerns :programs_routes
      resources :users, controller: 'accounts', path: 'comptes', as: 'accounts', only: [:index, :edit, :update] do
        get 'list_com', on: :collection,  as: 'kits', path: 'supports'
        get 'edit_com', on: :member, as: 'edit_kit', path: 'supports'
        patch 'update_com', on: :member
      end
    end
  end

  get 'en-savoir-plus', to: 'about#about', as: 'about'
  get 'partenaires', to: 'about#partners', as: 'partners'

  root to: 'user/dashboard#index'
end
