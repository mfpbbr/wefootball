class UserMailer < ActionMailer::Base
  def signup_notification(user)   
    setup_email(user)
    @subject    += '请激活您的帐号'
  
    @body[:url]  = "#{HOST}/activate/#{user.activation_code}"
  
  end
  
  def activation(user)
    setup_email(user)
    @subject    += '您的帐号已经被激活！'
    @body[:main_page_url]  = "#{HOST}/user_views/#{user.id}"
    @body[:edit_url]  = "#{HOST}/users/#{user.id}/edit"  
  end
  
  def forgot_password(user)
    setup_email(user)
    @subject    += '您要求更改密码'
    @body[:url]  = "#{HOST}/reset_password/#{user.password_reset_code}" 
  end

  def reset_password(user)
    setup_email(user)
    @subject    += '您的密码已经被更改'
    @body[:url]  = "#{HOST}/login"    
  end
  
  protected
    def setup_email(user)
      @recipients  = "#{user.login}"
      @from        = %("WeFootball" <welcome@wefootball.org>) # Sets the User FROM Name and Email
      @subject     = "[WeFootball]"
      @sent_on     = Time.now
      @body[:user] = user
    end

end