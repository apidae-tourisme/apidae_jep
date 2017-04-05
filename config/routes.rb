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
          patch 'set_opening', on: :member, as: 'opening'
        end
      end
    end
  end

  root to: 'user/dashboard#index'

  #
  # # defaults to dashboard
  # root :to => redirect('/dashboard/dashboard_v1')
  #
  # # view routes
  # get '/widgets' => 'widgets#index'
  # get '/documentation' => 'documentation#index'
  #
  # get 'dashboard/dashboard_v1'
  # get 'dashboard/dashboard_v2'
  # get 'dashboard/dashboard_v3'
  # get 'dashboard/dashboard_h'
  # get 'elements/button'
  # get 'elements/notification'
  # get 'elements/spinner'
  # get 'elements/animation'
  # get 'elements/dropdown'
  # get 'elements/nestable'
  # get 'elements/sortable'
  # get 'elements/panel'
  # get 'elements/portlet'
  # get 'elements/grid'
  # get 'elements/gridmasonry'
  # get 'elements/typography'
  # get 'elements/fonticons'
  # get 'elements/weathericons'
  # get 'elements/colors'
  # get 'elements/buttons'
  # get 'elements/notifications'
  # get 'elements/carousel'
  # get 'elements/tour'
  # get 'elements/sweetalert'
  # get 'forms/standard'
  # get 'forms/extended'
  # get 'forms/validation'
  # get 'forms/wizard'
  # get 'forms/upload'
  # get 'forms/xeditable'
  # get 'forms/imgcrop'
  # get 'multilevel/level1'
  # get 'multilevel/level3'
  # get 'charts/flot'
  # get 'charts/radial'
  # get 'charts/chartjs'
  # get 'charts/chartist'
  # get 'charts/morris'
  # get 'charts/rickshaw'
  # get 'tables/standard'
  # get 'tables/extended'
  # get 'tables/datatable'
  # get 'tables/jqgrid'
  # get 'maps/google'
  # get 'maps/vector'
  # get 'extras/mailbox'
  # get 'extras/timeline'
  # get 'extras/calendar'
  # get 'extras/invoice'
  # get 'extras/search'
  # get 'extras/todo'
  # get 'extras/profile'
  # get 'extras/contacts'
  # get 'extras/contact_details'
  # get 'extras/projects'
  # get 'extras/project_details'
  # get 'extras/team_viewer'
  # get 'extras/social_board'
  # get 'extras/vote_links'
  # get 'extras/bug_tracker'
  # get 'extras/faq'
  # get 'extras/help_center'
  # get 'extras/followers'
  # get 'extras/settings'
  # get 'extras/plans'
  # get 'extras/file_manager'
  # get 'blog/blog'
  # get 'blog/blog_post'
  # get 'blog/blog_articles'
  # get 'blog/blog_article_view'
  # get 'ecommerce/ecommerce_orders'
  # get 'ecommerce/ecommerce_order_view'
  # get 'ecommerce/ecommerce_products'
  # get 'ecommerce/ecommerce_product_view'
  # get 'ecommerce/ecommerce_checkout'
  # get 'forum/forum_categories'
  # get 'forum/forum_topics'
  # get 'forum/forum_discussion'
  # get 'pages/login'
  # get 'pages/register'
  # get 'pages/recover'
  # get 'pages/lock'
  # get 'pages/template'
  # get 'pages/notfound'
  # get 'pages/maintenance'
  # get 'pages/error500'
  #
  # # api routes
  # get '/api/documentation' => 'api#documentation'
  # get '/api/datatable' => 'api#datatable'
  # get '/api/jqgrid' => 'api#jqgrid'
  # get '/api/jqgridtree' => 'api#jqgridtree'
  # get '/api/i18n/:locale' => 'api#i18n'
  # post '/api/xeditable' => 'api#xeditable'
  # get '/api/xeditable-groups' => 'api#xeditablegroups'
  #
  # # the rest goes to root
  # get '*path' => redirect('/')
end
