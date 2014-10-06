Htwk2ical::Application.routes.draw do

  scope "(:locale)", :locale => /en|de/ do
    root :to                                => 'index#index'
    match "faq"                             => "index#faq", :as => 'faq'
    match "contact"                         => "index#contact", :as => 'contact'
    match "imprint"                         => "index#imprint", :as => 'imprint'
    match "calendar(/:subject_ids)"         => "calendar#choose_subjects", :constraints => {:subject_ids => /(-?\d+)+/}, :as => 'calendar'
    match "calendar/courses(/:subject_ids)" => "calendar#choose_courses", :constraints => {:subject_ids => /(-?\d+)+/}, :as => 'calendar_courses'
    match "calendar/link"                   => "calendar#get_link", :as => 'calendar_link'
  end

  match "/subjects"          => "calendar#get_subjects", :as => 'subjects', :defaults => {:format => 'json'}
  match "/studium_generales" => "calendar#get_studium_generales", :as => 'studium_generales', :defaults => {:format => 'json'}
  match ":calendar_secret"   => "calendar#get", :constraints => {:calendar_secret => /\w{8}/}, :as => 'calender_get', :defaults => {:format => 'ics'}
end
