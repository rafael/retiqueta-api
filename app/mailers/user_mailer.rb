class UserMailer < ApplicationMailer
  def signup_email(user)
    @user = user
    mail(to: @user.email)
  end

  def password_reset_email(user, token)
    @user = user
    @token = token
    mail(to: @user.email)
  end


  private

  helper do
    def password_reset_url(token)
      "https://retiqueta.com/password_resets?token=#{token}"
    end
  end
end
