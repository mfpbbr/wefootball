class SidedMatchJoin < ActiveRecord::Base

  UNDETERMINED = 0
  JOIN = 1
  
  CARDS = [0,1,2,3]
  
  belongs_to :sided_match, :foreign_key => 'match_id'
  belongs_to :user
  
  validates_inclusion_of   :position, :in => Team::FORMATION_POSITIONS, :allow_nil => true
  
  def before_validation
    self.position = nil if self.position==""
    if self.position!=nil
      ut = UserTeam.find_by_user_id_and_team_id(self.user_id, self.sided_match.host_team_id)
      self.position = nil if ut.nil? || !ut.is_player
    end
  end
  
  def self.create_joins(match)
    host_team = match.host_team
    for user in host_team.users
      mj = SidedMatchJoin.new
      mj.match_id = match.id
      mj.user_id = user.id
      mj.status = UNDETERMINED
      mj.save!
    end
  end
  
  def self.players(match)
    team_id = match.host_team_id
    match_id = match.id
    SidedMatchJoin.find(:all,
                   :select => 'mj.*',
                   :conditions => ["mj.match_id=? and ut.is_player=true",match_id],
                   :joins => "as mj inner join user_teams as ut on ut.team_id=#{team_id} and mj.user_id=ut.user_id"
                   )
  end
  
  def cards
    if !self.yellow_card.nil? && !self.red_card.nil?
      return self.yellow_card + self.red_card
    end
  end
  
  def cards=(type_num)
    result = MatchJoin.split_cards(type_num)
    self.yellow_card = result[0]
    self.red_card = result[1]
  end  
end