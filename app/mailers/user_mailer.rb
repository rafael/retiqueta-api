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

  def product_sale(sale)
    @user = sale.user
    mail(to: @user.email)
  end

  def order_created(order)
    @user = order.user
    mail(to: @user.email)
  end

  private

  helper do
    def password_reset_url(token)
      Rails.configuration.x.reset_password_url.gsub("{{token}}", token)
    end
  end
end
