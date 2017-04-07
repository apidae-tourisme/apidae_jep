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
    get '/oauth/auth/apidae/callback' => 'moderators/omniauth_callbacks#apidae'
  end

  authenticated :user do
    get '/', to: 'user/dashboard#index'
  end

  authenticated :moderator do
    get '/', to: 'moderator/dashboard#index'
  end

  namespace :user, path: 'saisie' do
    scope(path_names: {new: 'creer', edit: 'modifier'}) do
      resources :programs, path: 'programmations' do
        resources :program_items, path: 'offres' do
          get 'confirm', on: :member, path: 'confirmation'
          post 'duplicate', on: :member, as: 'duplicate'
          patch 'reorder', on: :member, as: 'reorder'
          get 'select_program', on: :member, as: 'select'
          patch 'save_program', on: :member, as: 'save'
          patch 'set_opening', on: :collection, as: 'opening'
          get 'update_form', on: :collection, as: 'update_form'
        end
      end
    end
  end

  root to: 'user/dashboard#index'
end
