class GamesController < ApplicationController
  # GET /games
  # GET /games.json
  def index
    @games = Game.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @games }
    end
  end

  # GET /games/1
  # GET /games/1.json
  def show
    @game = Game.find(params[:id])
    @cornbowlers = @game.cornbowlers.order("order_rank ASC")
    @frames = {}
    @cornbowlers.each do |cornbowler|
      @frames[cornbowler.id] = Frame.where(:game_id => @game.id, :cornbowler_id => cornbowler.id).order("number ASC")
    end
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @game }
    end
  end

  # GET /games/new
  # GET /games/new.json
  def new
    @game = Game.new
    @cornbowlers = Cornbowler.order("name ASC").all

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @game }
    end
  end

  # GET /games/1/edit
  def edit
    @game = Game.find(params[:id])
    @cornbowlers = @game.cornbowlers
  end

  # POST /games
  # POST /games.json
  def create
    @game = Game.new
    Rails.logger.debug params.inspect
    @game.add_cornbowlers_with_order_rank(params[:cornbowler_ids])

    respond_to do |format|
      if @game.save
        format.html { redirect_to @game, notice: 'Game was successfully created.' }
        format.json { render json: @game, status: :created, location: @game }
      else
        format.html { render action: "new" }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /games/1
  # PUT /games/1.json
  def update
    respond_to do |format|
      if @game.update_attributes(params[:game])
        format.html { redirect_to @game, notice: 'Game was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /games/1
  # DELETE /games/1.json
  def destroy
    @game = Game.find(params[:id])
    @game.destroy

    respond_to do |format|
      format.html { redirect_to games_url }
      format.json { head :no_content }
    end
  end

  # PUT /games/1/finish
  # PUT /games/1/finish.json
  def finish
    @game = Game.find(params[:id])
    @game.complete(params[:matchups])
    respond_to do |format|
      format.json { head :no_content }
    end
  end 
end
