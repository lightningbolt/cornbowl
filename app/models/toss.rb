class Toss < ActiveRecord::Base
  include ActiveUUID::UUID

  belongs_to :cornbowler
  belongs_to :frame

  validates_inclusion_of :score, :in => [0, 1, 3], :allow_nil => true
  validates_inclusion_of :number, :in => [0, 1, 2], :allow_nil => true
  validates_uniqueness_of :number, :scope => :frame_id, :allow_nil => true
 
  def formatted_score
    if self.strike?
      "X"
    elsif self.spare?
      "/"
    else
      self.score
    end
  end
  
  def score=(score)
    if %w{\\ / x X}.include?(score)
      write_attribute(:score, 3)
    else
      write_attribute(:score, score)
    end
  end

  def spare_or_strike?
    self.score == 3
  end

  def spare?
    self.spare_or_strike? && 
    self.number == 1 &&
    (self.frame.number != 10 || !self.frame.toss(0).strike?)
  end

  def strike?
    self.spare_or_strike? && 
    ([0, 2].include?(self.number) ||
     (self.frame.number == 10 && self.frame.toss(0).strike?))
  end
end
