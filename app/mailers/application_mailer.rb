class ApplicationMailer < ActionMailer::Base
  default from: Rails.application.credentials.gmail[:user_name] || ENV['GMAIL_USERNAME']
  layout "mailer"
end
