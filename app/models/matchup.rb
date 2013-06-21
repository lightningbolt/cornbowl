class Matchup < ActiveRecord::Base
  include ActiveUUID::UUID
  
  belongs_to :cornbowler
  belongs_to :game

  validates_uniqueness_of :cornbowler_id, :scope => :game_id
  validates_uniqueness_of :order_rank, :scope => :game_id
end
