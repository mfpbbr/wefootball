class TeamJoinsController < ApplicationController
  before_filter :login_required, :except => [:index]
  
  def index
    if (params[:user_id]) # 显示用户参加的所有队伍
      @uts = UserTeam.find_all_by_user_id(params[:user_id],:include=>[:team])
      render :action=>"index_team"
    else # 显示队伍的所有成员
      @uts = UserTeam.find_all_by_team_id(params[:team_id],:include=>[:user])
      @team_id = params[:team_id]
      render :action=>"index_user"
    end
  end  
  
  # POST /team_joins.xml
  def create
    @tjs = TeamJoinRequest.find(params[:id]) # 根据一个加入球队的请求来创建
    if !@tjs.can_accept_by?(self.current_user)
      fake_params_redirect
      return
    end
    
    @user =@tjs.user
    @team = @tjs.team
    if (@user.is_team_member_of?(@team)) #如果已经在球队中不能申请加入
      redirect_with_back_uri_or_default team_view_path(@tjs.team_id)
      return
    end    
    UserTeam.transaction do
      @tjs.destroy
      @tu = UserTeam.new
      @tu.team_id = @tjs.team_id
      @tu.user_id = @tjs.user_id
      @tu.save
    end
    redirect_with_back_uri_or_default team_view_path(@tjs.team_id)
  end
  
  # PUT team_joins/1
  def update
    @tj = UserTeam.find(params[:id])
    if (!current_user.is_team_admin_of?(@tj.team_id))
      fake_params_redirect
      return
    end    
    @user =@tj.user
    @team = @tj.team
    params[:ut][:position] = nil if params[:ut][:position]==""
    params[:ut][:is_player] = false if !@user.is_playable
    params[:ut][:position] = nil if (@team.formation.size > 11)
    tmp = UserTeam.new(:is_admin => params[:ut][:is_admin])
    params[:ut][:is_admin] = @tj.is_admin if(
      tmp.is_admin && !@tj.can_promote_as_admin_by?(current_user)||
      !tmp.is_admin && !@tj.can_degree_as_common_user_by?(current_user))
    if @tj.update_attributes(params[:ut])
      redirect_to team_team_joins_path(@team)
    else
      fake_params_redirect
    end
  end
  
  # DELETE team_joins/1
  def destroy
    @tj = UserTeam.find(params[:id])
    if (!@tj.can_destroy_by?(self.current_user))
      redirect_with_back_uri_or_default team_view_path(@tj.team_id)
    else
      @tj.destroy
      redirect_with_back_uri_or_default team_view_path(@tj.team_id)
    end
  end
end
