require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get session_new_url
    assert_response :success
  end

  test "should get create" do
    post session_create_url
    assert_response :success
  end

  test "should get delete" do
    get session_delete_url
    assert_response :success
  end

  test "should get result" do
    get session_result_url
    assert_response :success
  end
end
