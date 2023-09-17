class PasswordMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.password_mailer.reset.subject
  #
  def reset
    @user = params[:user]
    @token = params[:user].signed_id(purpose: 'password_reset', expires_in: 15.minute)

    mail to: params[:user].email
    mail subject: 'Password reset request'
  end
end
