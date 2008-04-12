class SidedMatch < ActiveRecord::Base
  include ModelHelper
  
  MAX_DESCRIPTION_LENGTH = 3000
  MAX_LOCATION_LENGTH = 100   
  
  MATCH_TYPES = [1,2]
  MATCH_SIZES = (5..11).to_a
  WIN_RULES = [1,2,3]  
  SITUATIONS = (1..8).to_a  
  
  has_many :sided_match_joins,
            :dependent => :destroy,
            :foreign_key => :match_id
          
  has_many :users, :through=>:sided_match_joins do
    def joined
      find :all, :conditions => ['status = ?', TrainingJoin::JOIN]
    end
    def undetermined
      find :all, :conditions => ['status = ?', TrainingJoin::UNDETERMINED]
    end
  end
            
  attr_protected :host_team_id
  
  validates_presence_of     :start_time, :message => "请填写比赛开始时间"
  
  validates_presence_of     :location, :message => "请填写比赛地点"
  validates_length_of :location, :maximum => MAX_LOCATION_LENGTH 
  
  validates_presence_of     :guest_team_name, :message => "请填写对方球队名称"
  
  validates_length_of        :guest_team_name,    :maximum => 50
  validates_inclusion_of   :situation, :in => SITUATIONS, :allow_nil=>true  
  validates_numericality_of :host_team_goal, :guest_team_goal, :allow_nil=>true
  
  validates_inclusion_of :match_type, :in => MATCH_TYPES
  validates_inclusion_of :size, :in => MATCH_SIZES
  validates_inclusion_of :win_rule, :in => WIN_RULES 

  validates_length_of  :description, :maximum =>MAX_DESCRIPTION_LENGTH, :allow_nil => true  
  
  
  belongs_to :host_team, :class_name=>"Team", :foreign_key=>"host_team_id"
  
  def before_save
    self.half_match_length = 0 if self.half_match_length.nil?
    self.rest_length = 0 if self.rest_length.nil?    
    self.end_time = self.start_time.since(60 * self.full_match_length)
  end
  
  def full_match_length
    2*self.half_match_length + self.rest_length
  end
  
  def before_validation
    self.description = "" if self.description.nil?
    self.match_type = 1 if self.match_type.nil?
    self.size = 5 if self.size.nil?
    self.win_rule = 1 if self.win_rule.nil?
    self.start_time = DateTime.now.tomorrow if self.start_time==nil
    self.half_match_length = 45 if self.half_match_length==nil
    self.rest_length = 15 if self.rest_length==nil
    attribute_slice(:description, MAX_DESCRIPTION_LENGTH)
  end

  def self.calculate_situation(host_team_goal,guest_team_goal)
    if(host_team_goal.nil? || guest_team_goal.nil?)
      return 1
    elsif(!host_team_goal.nil? && !guest_team_goal.nil?)
      return Match.calculate_situation_from_goal(host_team_goal,guest_team_goal)
    end
  end

  def is_before_match?
    return Time.now < self.start_time
  end
  
  def is_after_match?
    return Time.now > self.end_time
  end
  
  def can_be_created_by?(user)
    user.is_team_admin_of?(self.host_team_id)
  end

  def can_be_edited_by?(user)
    is_before_match? && user.is_team_admin_of?(self.host_team_id)
  end  
  
  def can_be_edited_result_by?(user)
    is_after_match? && user.is_team_admin_of?(self.host_team_id)
  end
  
  def can_be_edited_formation_by?(user)
    user.is_team_admin_of?(self.host_team_id)
  end

  def can_be_destroyed_by?(user)
    user.is_team_admin_of?(self.host_team_id)
  end
  
  def can_be_joined_by?(user)
    team_id = self.host_team_id
    is_before_match? && user.is_team_member_of?(team_id) && !has_joined_member?(user)
  end
  
  def can_be_quited_by?(user)
    team_id = self.host_team_id
    is_before_match? && user.is_team_member_of?(team_id) && has_member?(user)
  end
  
  def has_joined_member?(user)
    tj = has_member?(user)
    tj!=nil && tj.status == SidedMatchJoin::JOIN    
  end
  
  def has_member?(user)
    user_id = case user
    when User
      user.id
    else
      user
    end
    SidedMatchJoin.find :first, :conditions => ['user_id = ? and match_id = ?', user_id, self.id]
  end
end