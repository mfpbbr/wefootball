class UserTeam < ActiveRecord::Base
  include AttributesTracking
  
  FORMATION_MAX_LENGTH = 11  
  MAX_ADMIN_LENGTH = 20
  
  belongs_to :user
  belongs_to :team
  
  attr_protected :user_id, :team_id, :position
  
  validates_inclusion_of   :position, :in => Team::FORMATION_POSITIONS, :allow_nil => true, :message => "不要自己构造表单提交..."
  
  def before_validation
    self.position = nil if !self.is_player
    self.position = nil if self.position==""
  end
  
  def before_create
    false if self.is_admin && self.user.teams.count(:conditions => ["is_admin = ?", true]) >= MAX_ADMIN_LENGTH
  end
  
  def before_update
    if self.column_changed?(:is_admin)
      if self.is_admin && self.user.teams.count(:conditions => ["is_admin = ?", true]) >= MAX_ADMIN_LENGTH
        self.is_admin = false 
      elsif !self.is_admin && UserTeam.count(:conditions=>["team_id = ? and is_admin = ?",self.team_id,true])<=1
        self.is_admin = true 
      end
    end
    true
  end
  
  def self.team_formation(team)
    team_id = case team
    when Team
      team.id
    else
      team
    end
    UserTeam.find :all, :conditions => ['team_id = ? and position is not null', team_id]
  end
  
  def is_player_updated_to_false
    !self.is_player && self.column_changed?(:is_player)
  end
  
  def can_destroy_by?(user)
    (user.is_team_admin_of?(self.team_id) || self.user==user) && !is_the_only_one_admin?
  end
  
  def can_promote_as_admin_by?(user)
    !self.is_admin && user.is_team_admin_of?(self.team_id) && (self.user.teams.admin.size < MAX_ADMIN_LENGTH)
  end
  
  def can_degree_as_common_user_by?(user) 
    (self.is_admin) && (user.is_team_admin_of?(self.team_id)) && !is_the_only_one_admin?
  end

  def is_the_only_one_admin?
    self.is_admin && (UserTeam.count(:conditions=>["team_id = ? and is_admin = ?",self.team_id,true])==1)
  end
end
