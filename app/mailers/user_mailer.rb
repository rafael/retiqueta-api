# coding: utf-8
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

  def fulfillment_comment_created_for_seller(buyer, seller, comment, product)
    @buyer = buyer
    @seller = seller
    @comment = comment
    @product = product
    mail(to: @seller.email ,
         subject: I18n.t('user_mailer.fulfillment_comment_created_for_seller.subject',
                         text: comment.truncate_words(3)))
  end

  def fulfillment_comment_created_for_buyer(buyer, seller, comment, product)
    @buyer = buyer
    @seller = seller
    @comment = comment
    @product = product
    mail(to: @buyer.email,
         subject: I18n.t('user_mailer.fulfillment_comment_created_for_buyer.subject',
                         text: comment.truncate_words(3)))
  end

  def order_created(order)
    @user = order.user
    mail(to: @user.email)
  end

  def landing_welcome(email)
    mail(to: email)
  end

  def goodbye(email)
    mail(to: email, subject: 'Hasta pronto retilovers <3')
  end

  def welcome_2_0(email)
    mail(to: email, subject: 'Retiqueta cobrará comisión desde…')
  end

  def comment_created(user, commenter, product, text)
    @user = user
    @commenter = commenter
    @product = product
    @text = text
    mail(to: user.email,
         #from: "producto+#{product.uuid}@retiqueta.com",
         subject: I18n.t('user_mailer.comment_created.subject',
                         text: text.truncate_words(3)))
  end

  private

  helper do
    def password_reset_url(token)
      Rails.configuration.x.reset_password_url.gsub("{{token}}", token)
    end
  end
end
