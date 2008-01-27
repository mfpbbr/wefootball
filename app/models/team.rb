class Team < ActiveRecord::Base
  has_many :trainings,
            :dependent => :destroy
  
  has_many :user_teams,
            :dependent => :destroy
  has_many :users, :through=>:user_teams do
    def admin
      find :all, :conditions => ['is_admin = ?', true]
    end
  end
  
  has_many :team_join_requests,
            :dependent => :destroy
  
  validates_presence_of     :name, :shortname
  validates_length_of        :name,    :maximum => 200
  validates_length_of        :shortname,    :maximum => 20
  validates_length_of        :summary,    :maximum => 700
  validates_length_of        :style,    :maximum => 20
end
