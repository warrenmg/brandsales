Brandsales::Application.routes.draw do
  resources :orders
  resources :shopifystores
  
  match 'auth/shopify/callback' => 'login#finalize'
  
  match '/charge/confirm'    => 'charge#confirm', :as => :confirm
  match 'charge'             => 'charge#index', :as => :charge
  
  match 'home'      => 'home#index'
  match 'customergroups'      => 'customergroups#index'
  match 'customercountries'  => 'customercountries#index'
  match '/orders/search_orders/'     => 'orders#search_orders'
  match '/home/checkjob/'     => 'home#checkjob'
  
  match 'welcome'            => 'home#welcome'

  match 'design'             => 'home#design'

  match 'login'              => 'login#index',        :as => :login

  match 'login/authenticate' => 'login#authenticate', :as => :authenticate
 
  match 'login/finalize'     => 'login#finalize',     :as => :finalize

  match 'login/logout'       => 'login#logout',       :as => :logout
  
  
  match 'initial_pull'       => 'home#initial_pull', :as => 'initial_pull'
  match 'pull_all_orders'    => 'home#pull_all_orders', :as => 'pull_all_orders'
  match 'delayedjoborderfetch'    => 'home#delayedjoborderfetch', :as => 'delayedjoborderfetch'
  match 'orders'			     => 'orders#index'
  match '/home/select_orders_of_year' => "home#select_orders_of_year"
  root :to                   => 'home#index'

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
