class TrainsController < ApplicationController
  def index
    
  end
  
  def stuff
    @stuff =  TextQueue.all
    

    respond_to do |format|
      format.json { render :json => @stuff.to_json }
    end
  end
  
  def clockwork
    system ('rake clockwork')
    flash[:notice] = "sent some asshole a text"
    redirect_to action: "index"
  end
end
