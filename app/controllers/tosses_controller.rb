class TossesController < ApplicationController
  # GET /tosses/1
  # GET /tosses/1.json
  def show
    @toss = Toss.find(params[:id])

    respond_to do |format|
      format.json { render json: @toss }
    end
  end

  # POST /tosses
  # POST /tosses.json
  def create
    @toss = Toss.where(:frame_id => params[:frame_id], :number => params[:number]).first_or_initialize
    @toss.score = params[:score]
    
    WebsocketRails[@toss.frame.game.id.to_s].trigger(:tossed, { :frame_id => @toss.frame.id.to_s, :number => @toss.number, :score => @toss.score })
    respond_to do |format|
      if @toss.save
        format.json { render json: @toss, status: :created, location: @toss }
      else
        format.json { render json: @toss.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /tosses/1
  # PUT /tosses/1.json
  def update
    @toss = Toss.find(params[:id])

    respond_to do |format|
      if @toss.update_attributes(params[:toss])
        format.json { head :no_content }
      else
        format.json { render json: @toss.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tosses/1
  # DELETE /tosses/1.json
  def destroy
    @toss = Toss.find(params[:id])
    @toss.destroy

    respond_to do |format|
      format.json { head :no_content }
    end
  end
end
