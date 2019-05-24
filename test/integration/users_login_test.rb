require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
  end

  test "login with invalid information" do
    get login_path
    assert_template 'sessions/new', "login page doesn't get rendered"
    post login_path, params: {session: {email: "", password: ""}}
    assert_template 'sessions/new', "login page isn't rerendered on failure"
    assert_not flash.empty?, "flash doesn't show on login failure failure"
    get root_path
    assert flash.empty?, "flash shows on homepage"
  end

  test "login with valid information followed by logout" do 
    get login_path
    post login_path, params: {session: {email: @user.email, password: 'password'}}
    assert_redirected_to @user 
    follow_redirect!
    assert_template 'users/show'
    assert_select 'a[href=?]', login_path, count: 0
    assert_select 'a[href=?]', logout_path
    assert_select 'a[href=?]', user_path(@user)
    assert is_logged_in?

    delete logout_path
    assert_not is_logged_in?
    assert_redirected_to root_url
    # simulate user clicking logout on another window
    delete logout_path
    follow_redirect!
    assert_select 'a[href=?]', login_path 
    assert_select 'a[href=?]', logout_path, count: 0
    assert_select 'a[href=?]', user_path(@user), count: 0
  end

  test "authenticated? should return false for a user with nil remember digest" do 
    assert_not @user.authenticated? " "
  end

  test "Login with remembering" do 
    log_in_as(@user, remember_me: '1')
    assert_not_empty cookies[:remember_token]
  end

  test "Login without rememberint" do 
    log_in_as(@user, remember_me: '1')
    log_in_as(@user, remember_me: '0')
    assert_empty cookies[:remember_token]
  end
end
