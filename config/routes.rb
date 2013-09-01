Htwk2ical::Application.routes.draw do

  scope "(:locale)", :locale => /en|de/ do
    root :to => 'index#index'

    match "faq" => "index#faq",
          :as => 'faq'

    match "contact" => "index#contact",
          :as => 'contact'

    match "imprint" => "index#imprint",
          :as => 'imprint'

    match "calendar" => "calendar#choose_subjects",
          :as => 'calendar'

    match "calendar/courses" => "calendar#choose_courses",
          :as => 'calendar_courses'

    match "calendar/link" => "calendar#get_link",
          :as => 'calendar_link'

    match "cache" => "cache#index"
  end

  match "/subjects" => "calendar#get_subjects",
        :as => 'subjects',
        :defaults => { :format => 'json' }

  match ":calendar_secret" => "calendar#get",
        :constraints => { :calendar_secret => /\w{8}/ },
        :as => 'calender_get',
        :defaults => { :format => 'ics' }

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
  # just remember to delete public/_index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
