class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  # GET /users
  # GET /users.json
  def index
    @users = User.all

  end
  
  def setup
    @user = User.new
  end
  
  def unsubcribe
  
  end
  
  # GET /users/1
  # GET /users/1.json
  def show
  end

  def register
    @time = (Time.now - (600)).strftime("%H:%M")
    if params[:user_name] && params[:password]
      if User.create(phone: params[:user_name], password: params[:password])
        HTTParty.post("https://api.clockworksms.com/http/send.aspx", {query: {
             :key => "3cf1f7012e1ad38c8b0d36a32f18fc40673f7199", 
             :to => "#{params[:user_name]}", 
             :content => "The Time ten minutes ago was #{@time}"}})
        render status: 200
      else
        render status: 400
      end
    else
      render status: 400 , json: "Invalid params".to_json
    end
  end
  
  def login
    if params[:user_name] && params[:password]
      if User.find_by_phone_and_password(params[:user_name], params[:password])
        render status: 200
      else
        render status: 404
      end
    else
      render status: 400 , json: "Invalid params".to_json
    end
  end
    

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)
    if params[:commit] == "message" && params[:user][:from] && params[:user][:message]
        @user3 = User.where.not(phone: params[:user][:from]).order("RANDOM()").first
        HTTParty.post("https://api.clockworksms.com/http/send.aspx", {query: {
               :key => "3cf1f7012e1ad38c8b0d36a32f18fc40673f7199", 
               :to => "#{@user3.phone}",
               :from => "#{params[:user][:from]}",
               :content => "#{params[:user][:message]}"}}    
    end
    
    if params[:commit] == "delete" && params[:user][:phone]
      @user2 = User.find_by(phone: params[:user][:phone])
      if @user2 && @user2.destroy
          respond_to do |format|
            format.html { redirect_to action: :new, notice: 'User was successfully destroyed.' }
            format.json { head :no_content }
          end
      else
        respond_to do |format|
          format.html { redirect_to action: :new, notice: 'you do not exist' }
          format.json { head :no_content }
        end
      end
   else   
    if @user.save
      @time = (Time.now - (600)).strftime("%H:%M")
      HTTParty.post("https://api.clockworksms.com/http/send.aspx", {query: {
           :key => "3cf1f7012e1ad38c8b0d36a32f18fc40673f7199", 
           :to => "#{@user.phone}", 
           :from => "Rasputin",
           :content => "The Time ten minutes ago was #{@time}"}})
      respond_to do |format|
        format.html { redirect_to action: :new, notice: 'User was successfully created.' }
        format.json { render :new, status: :created, location: @user }
      end
    else
      respond_to do |format|
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
   end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:name, :email, :password, :phone)
    end
end
