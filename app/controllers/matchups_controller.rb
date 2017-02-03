class MatchupsController < ApplicationController
  # GET /high_scores
  # GET /high_scores.json
  def high_scores
    @matchups = Matchup.select("matchups.*, cornbowlers.name AS cornbowler_name").
      joins(:cornbowler).
      where("final_score IS NOT NULL").
      order("final_score DESC, cornbowler_name ASC").
      limit(25)

    rank = 1
    @high_scores_with_rank = @matchups.map.with_index do |matchup, i|
      previous_matchup = @matchups[i - 1]
      if previous_matchup && previous_matchup.final_score > matchup.final_score
        rank = i + 1
      elsif previous_matchup && previous_matchup.final_score == matchup.final_score
        rank = nil
      end
      {:rank => rank, :matchup => matchup}
    end
    respond_to do |format|
      format.html # high_scores.html.erb
      format.json { render json: @high_scores_with_rank }
    end
  end
end
