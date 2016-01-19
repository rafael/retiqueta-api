class UserMailer < ApplicationMailer
  def signup_email(user)
    @user = user
    mail(to: @user.email)
  end

  def password_reset_email(user)
    @user = user
    mail(to: @user.email)
  end


  private

  helper do
    def password_reset_url(user)
      "https://retiqueta.com/password_resets?token=#{user.password_reset_token}"
    end
  end
end
