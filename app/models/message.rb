class Message < ActiveRecord::Base
  belongs_to :sender, :class_name=>"User", :foreign_key=>"sender_id"
  belongs_to :receiver, :class_name=>"User", :foreign_key=>"receiver_id"
  
  validates_presence_of     :content, :subject
  validates_length_of       :content, :in =>5..2000
  validates_length_of       :subject, :maximum =>200
  
  def can_read_by(user)
    user_id = case user
    when User
      user.id
    else
      user
    end
    (self.sender_id == user_id && !self.is_delete_by_sender) || 
      (self.receiver_id == user_id && !self.is_delete_by_receiver)
  end
end
