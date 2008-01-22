require File.dirname(__FILE__) + '/../test_helper'

class UserTeamTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def test_through
    assert_equal 2,  users(:saki).teams.length
    assert_equal 2, users(:saki).teams.admin.length
    assert_equal 1,  users(:quentin).teams.length
    assert_equal 1,  users(:quentin).teams.admin.length
    assert_equal 1,  users(:aaron).teams.length
    assert_equal 0,  users(:aaron).teams.admin.length
    
    assert_equal 2,  teams(:inter).users.length
    assert_equal 2,  teams(:milan).users.length
    assert_equal 2,  teams(:inter).users.admin.length
    assert_equal 1,  teams(:milan).users.admin.length
  end
  
  def test_can_destroy
    assert user_teams(:aaron_milan).can_destroy_by?(users(:saki))
    assert user_teams(:aaron_milan).can_destroy_by?(users(:aaron))
    assert !user_teams(:aaron_milan).can_destroy_by?(users(:mike1))
    assert !user_teams(:saki_milan).can_destroy_by?(users(:saki))
  end
end