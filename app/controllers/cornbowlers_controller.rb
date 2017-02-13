class CornbowlersController < ApplicationController
  # GET /cornbowlers
  # GET /cornbowlers.json
  def index
    @cornbowlers = Cornbowler.order("name ASC").all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @cornbowlers }
    end
  end
 
  def login 
    if session[:user]
      redirect_to :controller => :games, :action => :index
    end
  end

  def auth
    user = Cornbowler.find_by_name params[:name]
    if user.nil?
      flash[:notice] = 'Please try again'
      redirect_to '/'
    else
      session[:user] = user
      redirect_to :controller => :games, :action => :index
    end
  end
  
  # GET /cornbowlers/1
  # GET /cornbowlers/1.json
  def show
    @cornbowler = Cornbowler.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @cornbowler }
    end
  end

  # GET /cornbowlers/new
  # GET /cornbowlers/new.json
  def new
    @cornbowler = Cornbowler.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @cornbowler }
    end
  end

  # GET /cornbowlers/1/edit
  def edit
    @cornbowler = Cornbowler.find(params[:id])
  end

  # POST /cornbowlers
  # POST /cornbowlers.json
  def create
    @cornbowler = Cornbowler.new(params[:cornbowler])

    respond_to do |format|
      if @cornbowler.save
        format.html { redirect_to @cornbowler, notice: 'Cornbowler was successfully created.' }
        format.json { render json: @cornbowler, status: :created, location: @cornbowler }
      else
        format.html { render action: "new" }
        format.json { render json: @cornbowler.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /cornbowlers/1
  # PUT /cornbowlers/1.json
  def update
    @cornbowler = Cornbowler.find(params[:id])

    respond_to do |format|
      if @cornbowler.update_attributes(params[:cornbowler])
        format.html { redirect_to @cornbowler, notice: 'Cornbowler was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @cornbowler.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cornbowlers/1
  # DELETE /cornbowlers/1.json
  def destroy
    @cornbowler = Cornbowler.find(params[:id])
    @cornbowler.destroy

    respond_to do |format|
      format.html { redirect_to cornbowlers_url }
      format.json { head :no_content }
    end
  end
end
