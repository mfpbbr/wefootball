class TeamsController < ApplicationController
  before_filter :login_required, :only=>[:create, :update]
  
  # GET /users/:user_id/teams.xml
  def index #列出用户参加的所有球队
    @user = User.find(params[:user_id])
    respond_to do |format|
      @teams = @user.teams
      format.xml  { render :xml => @teams.to_xml(:dasherize=>false, :except=>[:summary]), :status => 200 }
    end
  rescue ActiveRecord::RecordNotFound => e
    respond_to do |format|
      format.xml {head 404}
    end
  end
  
  # GET /teams/search.xml?query
  def search
    @teams = Team.find_by_contents(params[:query])
    respond_to do |format|
      format.xml  {
        render :xml=> @teams.to_xml(:dasherize=>false, :only=>[:id, :name, :shortname]), :status => 200 
      }
    end
  end

 # GET /teams/1.xml
  def show
    @team = Team.find(params[:id])
    respond_to do |format|
      format.xml  { render :xml => @team.to_xml(:dasherize=>false) }
    end
  rescue ActiveRecord::RecordNotFound => e
    respond_to do |format|
      format.xml {head 404}
    end
  end

  # POST /teams.xml
  def create
    @team = Team.new(params[:team])
    respond_to do |format|
      if @team.save
        @tu = UserTeam.new
        @tu.team = @team
        @tu.user = self.current_user
        @tu.is_admin = true
        @tu.save
        format.xml  { render :xml => @team.to_xml(:dasherize=>false), :status => 200, :location => @team }
      else
        format.xml  { render :xml => @team.errors.to_xml_full, :status => 200 }
      end
    end
  end

 # PUT /teams/1.xml
  def update
    @team = Team.find(params[:id])
    if (!@team.users.admin.include?(self.current_user))
      respond_to do |format|
        format.xml  { head 401 }
      end
      return
    end
    respond_to do |format|
      if @team.update_attributes(params[:team])
        format.xml  { render :xml => @team.to_xml(:dasherize=>false), :status => 200, :location => @team }
      else
        format.xml  { render :xml => @team.errors.to_xml_full, :status => 400 }
      end
    end
  rescue ActiveRecord::RecordNotFound => e
    respond_to do |format|
      format.xml {head 404}
    end
  end
  
   # GET /users/:user_id/teams/admin.xml
  def admin #列出用户参加的所有球队
    @user = User.find(params[:user_id])
    @teams = @user.teams.admin
    respond_to do |format|   
      format.xml  { render :xml => @teams.to_xml(:dasherize=>false, :only=>[:id,:shortname]), :status => 200 }
    end
  rescue ActiveRecord::RecordNotFound => e
    respond_to do |format|
      format.xml {head 404}
    end
  end

  protected
  def update_image
    if (@team.team_image==nil)
      @team.team_image = TeamImage.new
    end
    if @team.team_image.update_attributes({:uploaded_data => params[:team][:uploaded_data]})
      @team.save
      true
    else
      false
    end
  end
end
