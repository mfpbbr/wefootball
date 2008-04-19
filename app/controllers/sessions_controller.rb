class SessionsController < ApplicationController

  skip_before_filter :store_current_location
  
  def new
    render :layout => default_layout  
  end
  
  def create
    self.current_user = User.authenticate(params[:login], params[:password])
    if logged_in?
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies[:auth_token] = { :value => self.current_user.remember_token , 
          :expires => self.current_user.remember_token_expires_at }
      end
      @user = self.current_user
      redirect_back_or_default(user_view_path(@user))
    else
      render :action => 'new', :layout => default_layout  
    end
  end
  
  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "您已经登出WeFootball"
    redirect_with_back_uri_or_default new_session_path
  end
end
