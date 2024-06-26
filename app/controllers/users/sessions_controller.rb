# app/controllers/users/sessions_controller.rb
class Users::SessionsController < Devise::SessionsController
  respond_to :json

  private

  def respond_with(_resource, _opts = {})

    last_message_count = Participant.where(user_id: current_user.id).size

    render json: {
      message: 'You are logged in.',
      user: current_user.as_json.merge({
                                         last_message_count: last_message_count,
                                         followed_count: current_user.followings.size,
                                         followers_count: current_user.followers.size,
                                       })

    }, status: :ok
  end

  def respond_to_on_destroy
    log_out_success && return if current_user

    log_out_failure
  end

  def log_out_success
    render json: { message: 'You are logged out.' }, status: :ok
  end

  def log_out_failure
    render json: { message: 'Hmm nothing happened.' }, status: :unauthorized
  end
end
