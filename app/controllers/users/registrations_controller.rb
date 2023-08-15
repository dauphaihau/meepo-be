class Users::RegistrationsController < Devise::RegistrationsController
  respond_to :json

  private

  def sign_up_params
    params.require(:user).permit(:name, :email, :username, :password, :dob)
  end

  def account_update_params
    params.require(:user).permit(:name, :email, :username, :password, :dob)
  end

  def respond_with(resource, _opts = {})
    register_success && return if resource.persisted?
    register_failed
  end

  def register_success
    render json: {
      message: 'Signed up successfully.',
      user: current_user
    }, status: :ok
  end

  def register_failed
    @user_un = User.find_by_username(sign_up_params[:username])
    @user_e = User.find_by_email(sign_up_params[:email])
    message = ''
    message = 'username' if @user_un
    message = 'email' if @user_e
    message = 'username, email' if @user_e && @user_un

    if message
      render json: { message: 'Duplicate ' + message }, status: :conflict
    else
      render json: { message: 'Something went wrong.' }, status: :unprocessable_entity
    end
  end
end
