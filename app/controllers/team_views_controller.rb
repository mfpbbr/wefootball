class TeamViewsController < ApplicationController
  layout "team_layout"
  
  TRAINING_LIST_LENGTH = 1
  USER_LIST_LENGTH = 9
  POSTS_LENGTH = 10
  MATCH_LIST_LENGTH = 1
  DISPLAY_DAYS = 18
  
  def show
    @team = Team.find(params[:id])
    @users = @team.users.find(:all, :limit => USER_LIST_LENGTH)
    @posts = @team.posts.find(:all, :limit=> POSTS_LENGTH)
    
    tmp_tra = @team.trainings.recent(TRAINING_LIST_LENGTH)
    tmp_mat = Match.find :all,
      :conditions => ['(host_team_id = ? or guest_team_id = ?) and end_time > ?', @team.id, @team.id, Time.now],
      :order => 'start_time',
      :limit => MATCH_LIST_LENGTH
    @recent_training = tmp_tra.length > 0 ? tmp_tra[0] : nil
    @recent_matches = tmp_mat.length > 0 ? tmp_mat[0] : nil
    if @recent_training != nil && @recent_matches!=nil
      @recent_activity = @recent_training.start_time < @recent_matches.start_time ? @recent_training : @recent_matches
    else
      @recent_activity = @recent_training || @recent_matches
    end
    
    @calendar_activities_hash = 
      (@team.trainings.in_a_duration(Time.today, Time.today.since(3600*24*DISPLAY_DAYS)) +
       @team.match_calendar_proxy.in_a_duration(Time.today, Time.today.since(3600*24*DISPLAY_DAYS))).group_by{|t| t.start_time.strftime("%Y-%m-%d")}
    
    @formation_uts = UserTeam.find_all_by_team_id(@team.id, :conditions => ["position is not null"], :include => [:user])
    @formation_array = @formation_uts.map {|ut| ut.position}
    
    @user_team = logged_in? ? UserTeam.find_by_user_id_and_team_id(current_user, @team) : nil
    @team_join_request = logged_in? ? TeamJoinRequest.find_by_user_id_and_team_id_and_is_invitation(current_user, @team, false) : nil
    @team_join_invitation = logged_in? ? TeamJoinRequest.find_by_user_id_and_team_id_and_is_invitation(current_user, @team, true) : nil
    @can_request = logged_in? && @user_team == nil && @team_join_request == nil && @team_join_invitation==nil
    @can_quit = logged_in?  && @user_team != nil && # 可以退队
      @user_team.can_destroy_by?(current_user) # 处理唯一管理员的情况，唯一管理员不能退队
    
    @team_join_request_count = 0
    if logged_in? && current_user.is_team_admin_of?(@team)
      @team_join_request_count = TeamJoinRequest.count(:conditions => ["team_id = ? and is_invitation = ?", @team, false])
    end
    
    @title = "#{@team.shortname}的首页"
  end
end
