require File.dirname(__FILE__) + '/../test_helper'
require 'users_controller'

# Re-raise errors caught by the controller.
class UsersController; def rescue_action(e) raise e end; end

class UsersControllerTest < Test::Unit::TestCase
  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead
  # Then, you can remove it from this and the units test.
  include AuthenticatedTestHelper

  fixtures :users

  def setup
    @controller = UsersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_allow_signup
    assert_difference 'User.count' do
      create_user
      get :activate, :activation_code => assigns(:user).activation_code
      assert 'sakinijino@gmail.com', assigns["user"].login
      assert_redirected_to edit_user_path(assigns(:user))
    end
  end

  def test_should_require_login_on_signup
    assert_no_difference 'User.count' do
      create_user(:login => nil)
      assert assigns(:user).errors.on(:login)
      assert_template "new"
    end
  end
  
  def test_login_should_be_an_email_on_signup
    assert_no_difference 'User.count' do
      create_user(:login => 'saki')
      assert assigns(:user).errors.on(:login)
      assert_template "new"
    end
  end

  def test_should_require_password_on_signup
    assert_no_difference 'User.count' do
      create_user(:password => nil)
      assert assigns(:user).errors.on(:password)
      assert_template "new"
    end
  end

  def test_should_require_password_confirmation_on_signup
    assert_no_difference 'User.count' do
      create_user(:password_confirmation => nil)
      assert assigns(:user).errors.on(:password_confirmation)
      assert_template "new"
    end
  end  
  
  def test_update_success
    login_as :saki
    put :update, :id=>3, :user=>{:summary=>'Yada!!', :is_playable=>"1", :premier_position => 1}, :positions=>[1, 5]
    assert_equal 'Yada!!', assigns(:user).summary
    assert_equal 2, assigns(:user).positions.length
    assert_redirected_to edit_user_url(assigns(:user))
    put :update, :id=>3, :user=>{:is_playable=>"1"}
    assert_equal 1, assigns(:user).positions.length
    assert_equal 1, assigns(:user).premier_position
    assert_redirected_to edit_user_url(assigns(:user))
    put :update, :id=>3, :user=>{:is_playable=>"0"}, :positions=>[2, 3]
    assert_equal 0, assigns(:user).positions.length
    assert_redirected_to edit_user_url(assigns(:user))
  end
  
  def test_update_error
    login_as :quentin
    put :update, :id=>1, :user=>{:password=>'111111', :password_confirmation => '123'}
    assert assigns(:user).errors.on(:password)
    assert_template "edit"
  end
  
  def test_should_login_before_update_user
    put :update, :id=>1
    assert_redirected_to new_session_path
  end
  
  def test_should_not_update_other_user
    login_as :quentin
    put :update, :id=>2, :user=>{:nickname=>'saki@gmail.com'}
    assert_redirected_to "/"
  end
  
  def test_should_sign_up_user_with_activation_code
    create_user
    assigns(:user).reload
    assert_not_nil assigns(:user).activation_code
  end

  def test_should_activate_user
    create_user
    assert_nil User.authenticate(assigns(:user).login, 'quire')
    get :activate, :activation_code => assigns(:user).activation_code
    assert_redirected_to edit_user_path(assigns(:user))
    assert_equal assigns(:user), User.authenticate(assigns(:user).login, 'quire')
  end
  
  def test_should_not_activate_user_without_key
    get :activate
    assert_redirected_to "/"
  end

  def test_should_not_activate_user_with_blank_key
    get :activate, :activation_code => ''
    assert_redirected_to "/"
  end  
  
  def test_should_not_update_image_of_other_user
    login_as :quentin
    put :update_image, :id=>2, :user=>{}
    assert_redirected_to "/"
  end
  
  def test_should_not_get_edit_page_of_other_user
    login_as :quentin
    get :edit, :id=>2
    assert_redirected_to "/"
  end

  protected
    def create_user(options = {})
      post :create, :user => { :login => 'sakinijino@gmail.com',
        :password => 'quire', :password_confirmation => 'quire' }.merge(options)
    end
end
