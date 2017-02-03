class Game < ActiveRecord::Base
  include ActiveUUID::UUID

  has_many :cornbowlers, :through => :matchups
  has_many :frames, :dependent => :destroy
  has_many :matchups, :dependent => :destroy

  before_save :record_start_time
  after_create :create_frames

  def add_cornbowlers_with_order_rank(cornbowler_ids)
    cornbowler_ids.each_with_index do |id, i|
      if cornbowler = Cornbowler.find_by_id(id)
        self.matchups << Matchup.new(:cornbowler_id => cornbowler.id, :order_rank => i)
      end
    end
  end

  def complete(matchups = nil)
    return true if self.completed?
    if matchups
      complete_with_user_provided_data(matchups)
    else
      complete_with_database_data
    end
    self.update_attributes(:end_time => Time.now)
  end

  def completed?
    self.end_time.present?
  end
  alias_method :finished?, :completed?

  private

  def complete_with_database_data
    self.matchups.each do |matchup|
      frames = Frame.includes(:tosses).where(:game_id => self.id, :cornbowler_id => matchup.cornbowler_id).order("number ASC")
      frames.each do |frame|
        frame.update_attributes(:frame_score => frame.calculated_frame_score, :accumulated_score => frame.calculated_accumulated_score)
      end
      matchup.update_attributes(:final_score => frames.last.reload.accumulated_score)
    end
    winners = self.matchups.where(:final_score => self.matchups.maximum(:final_score))
    if winners.size == 1
      winners.first.cornbowler.standing.increment!(:wins)
    elsif winners > 1
      winners.each {|tied| tied.cornbowler.standing.increment!(:ties)}
    end
    (self.matchups - winners).each {|loser| loser.cornbowler.increment!(:losses)}
  end

  def complete_with_user_provided_data(matchups)
    matchups.each do |matchup_params|
      matchup = Matchup.find_by_game_id_and_cornbowler_id(self.id, UUIDTools::UUID.parse(matchup_params['cornbowler_id']))
      matchup.cornbowler.standing.increment!(matchup_params['result'])
      matchup.update_attributes(:final_score => matchup_params['final_score'])
      matchup_params['frames'].each do |frame_params|
        Frame.find(UUIDTools::UUID.parse(frame_params['frame_id'])).update_attributes(:frame_score => frame_params['frame_score'], :accumulated_score => frame_params['accumulated_score'])
      end
    end
  end

  def create_frames
    self.cornbowlers.each do |cornbowler|
      1.upto(10) do |i|
        self.frames << Frame.new(:cornbowler_id => cornbowler.id, :number => i)
      end
    end
  end

  def record_start_time
    self.start_time ||= Time.now
  end
end
