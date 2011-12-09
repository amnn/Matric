require 'test_helper'

class TestControllerTest < ActionController::TestCase
  test "should get setup" do
    get :setup
    assert_response :success
  end

  test "should get mc" do
    get :mc
    assert_response :success
  end

  test "should get ff" do
    get :ff
    assert_response :success
  end

end
