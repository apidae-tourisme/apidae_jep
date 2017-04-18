require 'test_helper'

class AboutControllerTest < ActionController::TestCase
  test "should get about" do
    get :about
    assert_response :success
  end

  test "should get partners" do
    get :partners
    assert_response :success
  end

end
