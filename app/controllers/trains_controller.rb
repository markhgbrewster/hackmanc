class TrainsController < ApplicationController
  def index
    
  end
  
  def clockwork
    system ('rake clockwork')
    flash[:notice] = "sent some asshole a text"
    redirect_to action: "index"
  end
end
