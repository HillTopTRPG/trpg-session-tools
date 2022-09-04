class Api::V1::UsersController < ApplicationController
  before_action :set_api_v1_user, only: %i[ show edit update destroy ]

  # GET /api/v1/users or /api/v1/users.json
  def index
    @api_v1_users = []
    if params[:room_uuid].nil?
      @api_v1_users = Api::V1::User.all
    else
      @api_v1_users = Api::V1::User.where(:room_uuid => params[:room_uuid])
    end

    respond_to do |format|
      format.html { render :index }
      format.json { render json: @api_v1_users.to_json(:except => [:password]) }
    end
  end

  # GET /api/v1/users/1 or /api/v1/users/1.json
  def show
  end

  # GET /api/v1/users/new
  def new
    @api_v1_user = Api::V1::User.new
  end

  # GET /api/v1/users/1/edit
  def edit
  end

  # POST /api/v1/users
  def create
    render json: { :verify => 'failed', :reason => 'no_such_room' } and return unless Api::V1::Room.exists?(:uuid => params[:api_v1_user][:room_uuid])
    render json: { :verify => 'failed', :reason => 'expire_room_token' } and return unless Api::V1::Token.valid.check_room(params[:api_v1_user][:room_uuid], params[:room_token])
    api_v1_user = Api::V1::User.new(api_v1_user_params)
    if api_v1_user.save
      api_v1_token = Api::V1::Token.new(:target_type => 'user', :room_uuid => api_v1_user.room_uuid, :user_uuid => api_v1_user.uuid)
      api_v1_token.save
      render json: { :verify => 'success', :token => api_v1_token.token, :user => api_v1_user.attributes.reject { |key| key == 'password' } }
    else
      render json: api_v1_user.errors
    end
  end

  # PATCH/PUT /api/v1/users/1 or /api/v1/users/1.json
  def update
    respond_to do |format|
      if @api_v1_user.update(api_v1_user_params)
        format.html { redirect_to api_v1_users_url, notice: "User was successfully updated." }
        format.json { render :show, status: :ok, location: @api_v1_user }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @api_v1_user.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /api/v1/users/1/verify
  def login
    render json: { :verify => 'failed', :reason => 'no_such_room' } and return unless Api::V1::Room.exists?(:uuid => params[:room_uuid])
    render json: { :verify => 'failed', :reason => 'expire_room_token' } and return unless Api::V1::Token.valid.check_room(params[:room_uuid], params[:room_token])

    api_v1_user = Api::V1::User.find_by(:uuid => params[:user_uuid], :room_uuid => params[:room_uuid])
    render json: { :verify => 'failed', :reason => 'no_such_user' } and return if api_v1_user.nil?
    #noinspection RubyNilAnalysis
    render json: { :verify => 'failed', :reason => 'invalid_password' } and return unless BCrypt::Password.new(api_v1_user.password).is_password?(params[:password])

    api_v1_token = Api::V1::Token.new(:target_type => 'user', :room_uuid => params[:room_uuid], :user_uuid => params[:user_uuid])
    api_v1_token.save
    render json: { :verify => 'success', :user_token => api_v1_token.token }
  end

  # POST /api/v1/token/verify/users
  def check_token
    api_v1_room = Api::V1::Room.find_by(:uuid => params[:room_uuid])
    render json: { :verify => 'failed', :reason => 'no_such_room' } and return if api_v1_room.nil?
    render json: { :verify => 'failed', :reason => 'expire_room_token' } and return unless Api::V1::Token.valid.check_room(params[:room_uuid], params[:room_token])

    #noinspection RubyNilAnalysis
    base = { :room => api_v1_room.attributes.reject { |key| key == 'password' }, :users => Api::V1::User.where(:room_uuid => params[:room_uuid]).map { |user| user.attributes.reject { |key| key == 'password' } } }
    render json: { :verify => 'failed', :reason => 'no_such_user', **base } and return unless Api::V1::User.exists?(:uuid => params[:user_uuid], :room_uuid => params[:room_uuid])
    render json: { :verify => 'failed', :reason => 'expire_user_token', **base } and return unless Api::V1::Token.valid.check_user(params[:room_uuid], params[:user_uuid], params[:user_token])
    render json: { :verify => 'success', **base }
  end

  def detail
    api_v1_user = Api::V1::User.find_by(:uuid => params[:user_uuid])
    if api_v1_user.nil?
      render json: nil
    else
      render json: api_v1_user.to_json(:except => ['password'])
    end
  end

  # DELETE /api/v1/users/1 or /api/v1/users/1.json
  def destroy
    @api_v1_user.destroy

    respond_to do |format|
      format.html { redirect_to api_v1_users_url, notice: "User was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_api_v1_user
    @api_v1_user = Api::V1::User.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def api_v1_user_params
    params.require(:api_v1_user).permit(:uuid, :name, :password, :room_uuid, :last_logged_in)
  end
end
