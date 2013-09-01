require 'test_helper'

class CalendarControllerTest < ActionController::TestCase
  test "should get get" do
    get :get
    assert_response :success
  end

  test "should get download" do
    get :download
    assert_response :success
  end

  test "should get choose_subjects" do
    get :choose_subjects
    assert_response :success
  end

  test "should get choose_custom_names" do
    get :choose_custom_names
    assert_response :success
  end

  test "should get choose_link" do
    get :choose_link
    assert_response :success
  end

end
