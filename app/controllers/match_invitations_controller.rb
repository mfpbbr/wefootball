class MatchInvitationsController < ApplicationController
  before_filter :login_required
  
  def new   
    @guest_team = Team.find(params[:guest_team_id])
    if !current_user.can_invite_team?(@guest_team)
      fake_params_redirect
      return
    end    
    @host_teams = current_user.teams.admin - [@guest_team]
  end
  
  def create
    @guest_team_id = params[:match_invitation][:guest_team_id]
    @host_team_id = params[:match_invitation][:host_team_id]
    if !current_user.can_invite_team?(@guest_team_id)
      fake_params_redirect
      return
    end
    @match_invitation = MatchInvitation.new(params[:match_invitation])
    @match_invitation.guest_team_id = @guest_team_id
    @match_invitation.host_team_id = @host_team_id
    @match_invitation.host_team_message = params[:match_invitation][:host_team_message]
    @match_invitation.edit_by_host_team = false
    if @match_invitation.save
      redirect_to team_view_path(@guest_team_id)
    else
      @guest_team = Team.find(@guest_team_id)
      @host_teams = current_user.teams.admin - [@guest_team]
      render :action=>"new"
    end
  end
  
  def edit   
    @match_invitation = MatchInvitation.find(params[:id],:include=>[:host_team,:guest_team])
    if !current_user.can_edit_match_invitation?(@match_invitation)
      fake_params_redirect
      return
    end
    @editing_by_host_team = @match_invitation.edit_by_host_team
  end
  
  def update   
    #首先将模型中的new属性平移到非new属性
    @match_invitation = MatchInvitation.find(params[:id])
    @match_invitation.save_last_info!
    @match_invitation.edit_by_host_team = !@match_invitation.edit_by_host_team
    if !@match_invitation.edit_by_host_team
      @match_invitation.host_team_message = params[:match_invitation][:host_team_message]        
    else
      @match_invitation.guest_team_message = params[:match_invitation][:guest_team_message]
    end
    if @match_invitation.update_attributes(params[:match_invitation])
      if !@match_invitation.edit_by_host_team       
        redirect_to team_view_path(@match_invitation.host_team_id)
      else
        redirect_to team_view_path(@match_invitation.guest_team_id)
      end   
    else
      render :action => "edit"
    end
  end   

  def accept
    match_invitation_id = params[:id]
    @match_invitation = MatchInvitation.find(match_invitation_id)
    if !current_user.can_accpet_match_invitation?(@match_invitation)
      fake_params_redirect
      return      
    end
    if @match_invitation.has_been_modified?(params[:match_invitation])#如果用户已经做过修改，则不能创建
      render :action => "edit", :id=>match_invitation_id
      return
    end
    Match.transaction do
      @match = Match.new_by_invitation(@match_invitation)
      @match.save!
      FriendInvitation.delete(params[:request_id])
    end
    redirect_to match_path(@match)
  end
  
  def destroy
    @match_invitation = MatchInvitation.find(params[:id])
    if !current_user.can_reject_match_invitation?(@match_invitation)
      fake_params_redirect
      return
    end
    MatchInvitation.destroy(@match_invitation)
    if @match_invitation.edit_by_host_team == true
      redirect_to team_view_path(@match_invitation.host_team_id)
    else
      redirect_to team_view_path(@match_invitation.guest_team_id)
    end
  end
  
end