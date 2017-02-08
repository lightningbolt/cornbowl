class MatchupsController < ApplicationController
  # GET /high_scores
  # GET /high_scores.json
  def high_scores
    @matchups = Matchup.select("matchups.*, cornbowlers.name AS cornbowler_name").
      joins(:cornbowler).
      where("final_score IS NOT NULL").
      order("final_score DESC, cornbowler_name ASC").
      limit(25)
    @high_scores_with_rank = object_hash_with_rank(@matchups, :final_score)

    respond_to do |format|
      format.html # high_scores.html.erb
      format.json { render json: @high_scores_with_rank }
    end
  end

  # GET /highest_averages
  # GET /highest_averages.json
  def highest_averages
    @averages = Matchup.joins(:cornbowler).
      select("cornbowlers.name AS cornbowler_name, COUNT(*) AS count, AVG(matchups.final_score) AS average_score").
      where("final_score IS NOT NULL").
      group("cornbowler_name").
      order("average_score DESC, cornbowler_name ASC").
      limit(25)
    @averages_with_rank = object_hash_with_rank(@averages, :average_score)

    respond_to do |format|
      format.html # highest_averages.html.erb
      format.json { render json: @averages }
    end
  end

  private

  def object_hash_with_rank(objects, comparison_field)
    rank = 1
    objects_with_rank = objects.map.with_index do |object, i|
      previous_index = i - 1
      if previous_index >= 0
        previous_object = objects[previous_index]
        if previous_object && previous_object.send(comparison_field) > object.send(comparison_field)
          rank = i + 1
        elsif previous_object && previous_object.send(comparison_field) == object.send(comparison_field)
          rank = nil
        end
      end
      {:rank => rank, :object => object}
    end
    objects_with_rank
  end
end
