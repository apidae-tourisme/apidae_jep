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
    get '/inactive', to: 'moderator/dashboard#inactive', as: 'moderator_inactive'
  end

  concern :programs_routes do
    resources :program_items, path: 'offres', as: 'items', only: [] do
      get :account, on: :collection, path: 'compte'
      get :entity, on: :collection, path: 'structure'
      get :export, on: :collection, path: 'export'
      get :entities, on: :collection, path: 'structures/autocomplete'
      get :places, on: :collection, path: 'places/autocomplete'
    end

    resources :program_items, path: 'offres' do
      get :confirm, on: :member, path: 'confirmation'
      post :duplicate, on: :member, as: 'duplicate'
      patch :reorder, on: :member, as: 'reorder'
      get :select_program, on: :member, as: 'select'
      patch :save_program, on: :member, as: 'save'
      patch :set_opening, on: :collection, as: 'opening'
      get :update_form, on: :collection, as: 'update_form'
      get :site_desc, on: :collection, as: 'site_desc'
      get 'brouillons(/:year)', on: :collection, as: 'drafts', to: 'program_items#index', status: ProgramItem::STATUS_DRAFT
      get 'validations(/:year)', on: :collection, as: 'pending', to: 'program_items#index', status: ProgramItem::STATUS_PENDING
      get 'publiees(/:year)', on: :collection, as: 'validated', to: 'program_items#index', status: ProgramItem::STATUS_VALIDATED
      get 'rejetees(/:year)', on: :collection, as: 'rejected', to: 'program_items#index', status: ProgramItem::STATUS_REJECTED
      match ':year', on: :collection, to: 'program_items#index', via: :get, as: 'annual', year: /20\d{2}/
    end
  end

  namespace :user, path: 'saisie' do
    scope(path_names: {new: 'creer', edit: 'modifier'}) do
      concerns :programs_routes
      resource :user, controller: 'account', path: 'compte', as: 'account', only: [:edit, :update] do
        get :search_entity, on: :collection, as: 'search_entity'
        get :towns, on: :collection, as: 'towns'
        get :search, on: :collection, as: 'search'
        get :communication, on: :collection
        patch :update_communication, on: :collection, as: 'com_poll'
      end
      resources :users, only: [], path: 'organisateurs' do
        resource :event_polls, path: 'questionnaire', only: [:new, :create, :show]
      end
      get :onboarding, to: 'dashboard#onboarding', path: 'onboarding'
      post :submit_onboarding, to: 'dashboard#submit_onboarding'
      get :support, to: 'dashboard#support', path: 'support'
    end
  end

  namespace :moderator, path: 'validation' do
    scope(path_names: {new: 'creer', edit: 'modifier'}) do
      concerns :programs_routes
      resources :users, controller: 'accounts', path: 'comptes', as: 'accounts', only: [:index, :new, :create, :edit, :update] do
        get :list_com, on: :collection,  as: 'kits', path: 'supports'
        get :new_com, on: :member, as: 'new_kit', path: 'supports'
        get :edit_com, on: :member, as: 'edit_kit', path: 'supports'
        patch :update_com, on: :member
        get :export, on: :collection, path: 'export'
        get :export_com, on: :collection, as: 'export_kits', path: 'export_supports'
        patch :notify_com, on: :collection
      end
      resources :event_polls, path: 'questionnaires', only: [:index, :show] do
        get :export, on: :collection
        patch :notify, on: :collection
      end
    end
  end

  namespace :api, path: 'api' do
    get 'offres/json_example', to: 'program_items#json_example'
    get 'offres/:ref', to: 'program_items#index'
  end

  get 'en-savoir-plus', to: 'about#about', as: 'about'
  get 'partenaires', to: 'about#partners', as: 'partners'

  root to: 'user/dashboard#index'
end
