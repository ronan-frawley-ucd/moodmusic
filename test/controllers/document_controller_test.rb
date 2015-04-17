require 'test_helper'

class DocumentControllerTest < ActionController::TestCase
  test "should get policy" do
    get :policy
    assert_response :success
  end

  test "should get contact" do
    get :contact
    assert_response :success
  end

end
