class UsersController < ApplicationController
  before_action :set_user, only: %i[ show edit update destroy]
  respond_to :json

  # PATCH/PUT /users/1 or /users/1.json
  def update
    if current_user.update(user_params)
      render json: current_user, status: :ok
    else
      render json: current_user.errors, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:avatar_url, :name, :bio, :location, :dob, :website)
  end

  def set_user
    begin
      select_string = 'id, name, username, avatar_url, dob, bio, website, location, posts_count'
      @user = User.select(select_string).find_by username: params[:id]
      if @user.nil?
        @user = User.select(select_string).find params[:id]
      end

    rescue ActiveRecord::RecordNotFound
      render json: {
        message: 'this user doesn’t exist'
      }, status: :not_found
      return

    end

  end
end
