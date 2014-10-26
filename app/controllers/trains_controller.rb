class TrainsController < ApplicationController
  def index
    
  end
  
  def stuff
    respond_to do |format|
      format.json { }
    end
  end
  
  def clockwork
    system ('rake clockwork')
    flash[:notice] = "sent some asshole a text"
    redirect_to action: "index"
  end
end
