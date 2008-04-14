class FootballGround < ActiveRecord::Base
  include ModelHelper
  
  belongs_to :user
  
  has_many :trainings, 
    :extend => ActivityCalendar
  
  has_many :matches, 
    :extend => ActivityCalendar

  has_many :sided_matches, 
    :extend => ActivityCalendar   
    # comment this, since it set football_ground_id to null before we can modity the location
    # :dependent => :nullify
  
  has_many :plays, 
    :extend => ActivityCalendar
  
  GROUND_TYPE = (1..5).to_a #天然草场、人工草场、硬地场、土场、室内场
  STATUS = (0..2).to_a #待审核、通过、停用
  
  validates_presence_of     :name, :message => "球场名称不能为空"
  validates_length_of        :name,    :maximum => 50
  
  validates_inclusion_of :ground_type, :in => GROUND_TYPE
  validates_inclusion_of :status, :in => STATUS
  
  validates_length_of        :description,    :maximum => 5000, :allow_nil => true
  
  def merge_to_and_delete(fg)
    FootballGround.transaction do
      Training.update_all(["location = ?", fg.name], ["football_ground_id = ?", self.id])
      Training.update_all(["football_ground_id = ?", fg.id], ["football_ground_id = ?", self.id])
      Play.update_all(["location = ?", fg.name], ["football_ground_id = ?", self.id])
      Play.update_all(["football_ground_id = ?", fg.id], ["football_ground_id = ?", self.id])
      Match.update_all(["location = ?", fg.name], ["football_ground_id = ?", self.id])
      Match.update_all(["football_ground_id = ?", fg.id], ["football_ground_id = ?", self.id])
      SidedMatch.update_all(["location = ?", fg.name], ["football_ground_id = ?", self.id])
      SidedMatch.update_all(["football_ground_id = ?", fg.id], ["football_ground_id = ?", self.id])
      FootballGround.delete(self.id)
    end
  end
  
  def before_destroy
    Training.update_all(["location = ?", self.name], ["football_ground_id = ?", self.id])
    Training.update_all("football_ground_id = NULL", ["football_ground_id = ?", self.id])
    Play.update_all(["location = ?", self.name], ["football_ground_id = ?", self.id])
    Play.update_all("football_ground_id = NULL", ["football_ground_id = ?", self.id])
    Match.update_all(["location = ?", self.name], ["football_ground_id = ?", self.id])
    Match.update_all("football_ground_id = NULL", ["football_ground_id = ?", self.id])
    SidedMatch.update_all(["location = ?", self.name], ["football_ground_id = ?", self.id])
    SidedMatch.update_all("football_ground_id = NULL", ["football_ground_id = ?", self.id])
  end
  
  def before_validation
    attribute_slice(:name, 50)
    attribute_slice(:description, 5000)
  end
  
  attr_protected :status, :user_id
end
