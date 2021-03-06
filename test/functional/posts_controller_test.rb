require File.dirname(__FILE__) + '/../test_helper'

class PostsControllerTest < ActionController::TestCase
  def test_should_get_team_index
    get :index, :team_id => 1
    assert_response :success
    assert_equal 5, assigns(:posts).length
  end
  
  def test_should_get_training_index
    get :index, :training_id => 1
    assert_response :success
    assert_equal 2, assigns(:posts).length
  end
  
  def test_should_get_sided_match_index
    get :index, :sided_match_id => 1
    assert_response :success
    assert_equal 2, assigns(:posts).length
  end
  
  def test_should_get_match_index
    get :index, :match_id => 1, :team_id => 1
    assert_response :success
    assert_equal 1, assigns(:posts).length
  end
  
  def test_should_get_watch_index
    get :index, :watch_id => 1
    assert_response :success
    assert_equal 2, assigns(:posts).length
  end  
  
  def test_should_get_team_index_private
    login_as :saki
    get :index, :team_id => 1
    assert_response :success
    assert_equal 9, assigns(:posts).length
  end
  
  def test_should_get_training_index_private
    login_as :saki
    get :index, :training_id => 1
    assert_response :success
    assert_equal 3, assigns(:posts).length
  end
  
  def test_should_get_sided_match_index_private
    login_as :saki
    get :index, :sided_match_id => 1
    assert_response :success
    assert_equal 3, assigns(:posts).length
  end
  
  def test_should_get_match_index_private
    login_as :saki
    get :index, :match_id => 1, :team_id => 1
    assert_response :success
    assert_equal 2, assigns(:posts).length
  end
  
  def test_should_get_watch_index_private
    login_as :saki    
    get :index, :watch_id => 1
    assert_response :success
    assert_equal 3, assigns(:posts).length
  end    
  
  def test_get_show_can_reply
    login_as :quentin
    get :show, :id => posts(:saki_1).id
    assert_select "#content form[action=#{post_replies_path(assigns(:post), :page => 1, :anchor=>'reply_form')}]"
  end
  
  def test_get_show_can_not_reply
    login_as :aaron
    get :show, :id => posts(:saki_1).id
    assert_select "#content form", 0
  end
  
  def test_get_show_without_logged_in
    get :show, :id => posts(:saki_1).id
    assert_select "#content form", 0
  end
  
  def test_get_show_private_noauth
    login_as :aaron
    get :show, :id => posts(:saki_3).id
    assert_fake_redirected
  end
  
  def test_get_show_private_without_logged_in
    get :show, :id => posts(:saki_3).id
    assert_fake_redirected
  end
  
  def test_get_new_noauth
    login_as :aaron
    get :new, :team_id => teams(:inter).id
    assert_fake_redirected
    get :new, :training_id => 1
    assert_fake_redirected   
  end
  
  def test_get_watch_new_noauth
    login_as :mike1
    get :new, :watch_id => 1
    assert_fake_redirected   
  end  
  
  def test_get_edit_noauth
    login_as :quentin
    get :edit, :id=> posts(:saki_1)
    assert_fake_redirected
  end
  
  def test_should_create_post
    login_as :quentin
    assert_difference('Post.count') do
    assert_difference('TrainingPost.count') do
    assert_difference('Training.find(trainings(:training1).id).team.posts.length') do
    assert_difference('Training.find(trainings(:training1).id).posts.length') do
      post :create, :training_id=>trainings(:training1).id, :post => { :title => 'Test', :content => '123456'}
    end
    end
    end
    end
    assert_equal users(:quentin).id, assigns(:post).user_id
    assert_redirected_to post_path(assigns(:post))
    
    assert_difference('Post.count') do
    assert_difference('SidedMatchPost.count') do
    assert_difference('SidedMatch.find(sided_matches(:one).id).team.posts.length') do
    assert_difference('SidedMatch.find(sided_matches(:one).id).posts.length') do
      post :create, :sided_match_id=>sided_matches(:one).id, :post => { :title => 'Test', :content => '123456'}
    end
    end
    end
    end
    assert_equal users(:quentin).id, assigns(:post).user_id
    assert_redirected_to post_path(assigns(:post))
    
    assert_difference('Post.count') do
    assert_difference('MatchPost.count') do
    assert_difference('Team.find(teams(:inter).id).posts.length') do
    assert_difference('Match.find(matches(:one).id).posts.team(teams(:inter)).length') do
      post :create, :match_id=>matches(:one).id, :team_id=>teams(:inter).id, :post => { :title => 'Test', :content => '123456'}
    end
    end
    end
    end
    assert_equal users(:quentin).id, assigns(:post).user_id
    assert_redirected_to post_path(assigns(:post))
    
    assert_difference('Post.count') do
    assert_difference('Team.find(teams(:inter).id).posts.length') do
      post :create, :team_id=>teams(:inter).id, :post => { :title => 'Test', :content => '123456'}
    end
    end
    assert_equal users(:quentin).id, assigns(:post).user_id
    assert_redirected_to post_path(assigns(:post))
    
    assert_difference('Post.count') do
    assert_difference('WatchPost.count') do
    assert_difference('Watch.find(1).posts.length') do
      post :create, :watch_id=>1, :post => { :title => 'Test', :content => '123456'}
    end
    end
    end
    assert_equal users(:quentin).id, assigns(:post).user_id
    assert_redirected_to post_path(assigns(:post))    
  end

  def test_should_update_post
    login_as :saki
    put :update, :id => posts(:saki_1).id, :post => { :content => '123456' }
    assert_equal '123456', assigns(:post).content
    assert_redirected_to post_path(assigns(:post))
  end
  
  def test_update_noauth
    login_as :quentin
    put :update, :id => posts(:saki_1).id, :post => { :content => '123456' }
    assert_fake_redirected
  end

  def test_should_destroy_post
    login_as :quentin
    assert_difference('Post.count', -1) do
      delete :destroy, :id => posts(:saki_4).id
    end
    assert_redirected_to team_posts_url(posts(:saki_4).team_id)
  end
  
  def test_should_destroy_post_redirect
    login_as :saki
    delete :destroy, :id => posts(:saki_12).id
    assert_redirected_to watch_posts_url(posts(:saki_12).activity_id)
    
    delete :destroy, :id => posts(:saki_1).id
    assert_redirected_to training_posts_url(posts(:saki_1).activity_id)
    
    delete :destroy, :id => posts(:saki_5).id
    assert_redirected_to match_team_posts_url(posts(:saki_5).activity_id, posts(:saki_5).team_id)
    
    delete :destroy, :id => posts(:saki_9).id
    assert_redirected_to sided_match_posts_url(posts(:saki_9).activity_id)
    
    posts(:saki_2).activity_id = nil
    posts(:saki_2).save
    delete :destroy, :id => posts(:saki_2).id
    assert_redirected_to team_posts_url(posts(:saki_2).team_id)
  end
  
  def test_destroy_post_unauth
    login_as :aaron
    assert_no_difference('Post.count') do
      delete :destroy, :id => posts(:saki_1).id
    end
    assert_fake_redirected
  end
end
