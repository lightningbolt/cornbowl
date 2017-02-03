class Cornbowler < ActiveRecord::Base
  include ActiveUUID::UUID
  
  has_many :frames
  has_many :games, :through => :matchups, :dependent => :destroy
  has_many :matchups, :dependent => :destroy
  has_many :tosses, :through => :frames

  has_one :standing, :dependent => :destroy

  after_create :create_standing
 
  validates :name, :uniqueness => { :case_sensitive => false }, :allow_blank => false

  def ace_percentage
    self.tosses.where(:score => 1).count / self.tosses.count.to_f
  end

  def average_final_score
    completed_matchups.average(:final_score)
  end

  def cornhole_percentage
    self.tosses.where(:score => 3).count / self.tosses.count.to_f
  end

  def field_goal_percentage
    self.tosses.where(:score => [1,3]).count / self.tosses.count.to_f
  end

  def high_score
    completed_matchups.maximum(:final_score)
  end

  def record
    standing = self.standing
    "#{standing.wins}-#{standing.losses}-#{standing.ties}"
  end

  def spare_percentage
    spare_opportunities = tosses_with_previous_toss.where("previous_tosses.score != 3 OR tosses.number = 1")
    spares_scored = spare_opportunities.where(:tosses => {:score => 3})
    spares_scored.count / spare_opportunities.count.to_f
  end

  def strike_percentage
    strike_opportunities = tosses_with_previous_toss.where("previous_tosses.score = 3 OR tosses.number IN(0,2)")
    strikes_scored = strike_opportunities.where(:tosses => {:score => 3})
    strikes_scored.count / strike_opportunities.count.to_f
  end

  private

  def create_standing
    self.standing = Standing.new
  end

  def completed_matchups
    self.matchups.joins(:game).where("games.end_time IS NOT NULL")
  end

  def tosses_with_previous_toss
    self.tosses.joins("LEFT JOIN tosses previous_tosses ON frames.id = previous_tosses.frame_id AND tosses.number = previous_tosses.number + 1")
  end
end
