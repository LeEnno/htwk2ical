Rails.application.routes.draw do
  scope "(:locale)", :locale => /en|de/, :constraints => -> (req) { req.format.to_s =~ /html/ } do
    root :to                                => 'index#index'
    get "donate"                          => "index#donate", :as => 'donate'
    get "donate/thx"                      => "index#donate_thx", :as => 'donate_thx'
    get "faq"                             => "index#faq", :as => 'faq'
    get "contact"                         => "index#contact", :as => 'contact'
    get "imprint"                         => "index#imprint", :as => 'imprint'
    get "privacy"                         => "index#privacy", :as => 'privacy'
    get "calendar(/:subject_ids)"         => "calendar#choose_subjects", :constraints => {:subject_ids => /(-?\d+)+/}, :as => 'calendar'
    get "calendar/courses(/:subject_ids)" => "calendar#choose_courses", :constraints => {:subject_ids => /(-?\d+)+/}, :as => 'calendar_courses'
    post "calendar/link"                   => "calendar#get_link", :as => 'calendar_link'
  end

  get "/subjects"          => "calendar#get_subjects", :defaults => {:format => 'json'}, :as => 'subjects'
  get "/studium_generales" => "calendar#get_studium_generales", :defaults => {:format => 'json'}, :as => 'studium_generales'
  get ":calendar_secret"   => "calendar#get", :constraints => {:calendar_secret => /\w{8}/, :format => 'ics'}, :defaults => {:format => 'ics'}, :as => 'calender_get'
end
