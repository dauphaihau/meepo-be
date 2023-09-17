class PasswordResetsController < ApplicationController

  # POST /users/password/reset
  def create
    unless params[:query]
      render json: {}, status: :bad_request
    end

    user = User.find_by("email = ? OR username = ?", params[:query], params[:query])
    if user.present?
      PasswordMailer.with(user: user).reset.deliver_now
      # PasswordMailer.with(user: user).reset.deliver_later
      render json: { message: 'OK', status: '200'
      }, status: :ok

    else
      render json: { message: 'user not found', status: 404 }, status: :not_found
    end
  end

  # PATCH /users/password/reset
  def edit
    rescue_invalid_signature do
      user = User.find_signed!(params[:token], purpose: "password_reset")
      if user.present?
        render json: { message: 'OK', status: '200' }, status: :ok
      end
    end
  end

  # PUT /users/password/reset
  def update
    rescue_invalid_signature do
      user = User.find_signed!(params[:token], purpose: "password_reset")
      if user.update({ password: params[:password] })
        token = user.signed_id(purpose: 'password_reset', expires_in: 15.minute)
        puts token
        render json: {
          code: 200,
          user: user,
          message: 'Your password was reset successfully'
        }
      else
        render status: :bad_request
      end
    end
  end

  private

  def rescue_invalid_signature(&block)
    begin
      block.call
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      logger.error 'Invalid or expired token'
      render json: {
        status: 401,
        message: 'Invalid or expired token'
      }, status: :unauthorized
    end
  end

end
