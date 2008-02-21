class TeamJoinRequest < ActiveRecord::Base
  belongs_to :user
  belongs_to :team
  
  validates_length_of  :message, :maximum => 500
  
  def before_create
    self.apply_date = Date.today
  end
  
  def can_destroy_by?(user)
    return (self.user == user) || (user.is_team_admin_of?(self.team))
  end
  
  def can_accept_by?(user)
    return (self.is_invitation && user==self.user) || 
      (!self.is_invitation && user.is_team_admin_of?(self.team))
  end
end
