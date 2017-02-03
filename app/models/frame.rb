class Frame < ActiveRecord::Base
  include ActiveUUID::UUID

  belongs_to :game
  belongs_to :cornbowler
  has_many :tosses, :dependent => :destroy

  validates_uniqueness_of :number, :scope => [:game_id, :cornbowler_id]

  def calculated_frame_score
    if self.tenth_frame?
      self.raw_score
    else
      self.raw_score + self.compound_score
    end
  end

  def calculated_accumulated_score
    Frame.where(:game_id => self.game_id,
                :cornbowler_id => self.cornbowler_id).
          where("number <= ?", self.number).inject(0) {|sum, prev_frame| sum += (prev_frame.frame_score || prev_frame.calculated_frame_score)}
  end

  def closed_frame?
    if !self.tenth_frame?
      self.raw_score == 3
    else
      self.toss(0).score == 3 || self.toss(1).score == 3
    end
  end

  def complete_frame?
    self.complete_non_tenth_frame? || self.complete_tenth_frame?
  end

  def complete_non_tenth_frame?
    !self.tenth_frame? && 
    (self.frame_score || 
      (self.toss_score(0) ==  3 || (self.toss_score(0).present? && self.toss_score(1).present?)))
  end

  def complete_tenth_frame?
    self.tenth_frame? && 
    (self.frame_score ||
      ((self.toss_score(0).present? && self.toss_score(1).present? && self.toss_score(2).present?) || (self.toss_score(0).present? && self.toss_score(1).present? && self.toss_score(1) != 3)))
  end

  def compound_score
    if self.tenth_frame?
      0
    elsif (first_toss = self.toss(0)).present? && first_toss.strike?
      tosses = Toss.select("tosses.score").
                    joins(:frame).
                    where(:frame_id => self.next_frame_ids(2)).
                    order("frames.number ASC, tosses.number ASC").
                    limit(2)
      # if next two tosses are in the same frame and that frame is a spare, then the compound score is 3 and not the sum of the two frames
      if (tosses[0].frame_id == tosses[1].frame_id) && tosses[1].spare?
        3
      else
        tosses.sum(&:score)
      end 
    elsif (second_toss = self.toss(1)).present? && second_toss.spare?
      Toss.select("tosses.score").
           joins(:frame).
           where(:frame_id => self.next_frame_ids(1)).
           order("frames.number ASC, tosses.number ASC").
           limit(1).
           sum(&:score)
    else
      0
    end
  end

  def open_frame?
    !self.closed_frame?
  end

  def next_frames(number)
    frame_numbers = 1.upto(number).map {|i| self.number + i}
    Frame.where(:game_id => self.game_id, :cornbowler_id => self.cornbowler_id, :number => frame_numbers)
  end

  def next_frame_ids(number)
    self.next_frames(number).select("id").map(&:id)
  end

  def raw_score
    raw_score = Toss.where(:frame_id => self.id).sum(:score)
    !self.tenth_frame? && raw_score > 3 ? 3 : raw_score    
  end

  def tenth_frame?
    self.number == 10
  end

  def toss(number)
    self.tosses.where(:number => number).first
  end

  def toss_formatted_score(number)
    if toss = toss(number)
      toss.formatted_score
    end
  end

  def toss_score(number)
    if toss = toss(number)
      toss.score
    end
  end
end
