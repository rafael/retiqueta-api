require 'rails_helper'

RSpec.describe UserMailer do
  let(:user) { build(:user) }

  describe ".send_signup_email" do
    let(:mail) { UserMailer.signup_email(user) }

    it "sets subject with i18n convention" do
      expect(mail.subject).to eq(I18n.t("user_mailer.signup_email.subject"))
    end

    it "sets sender to default" do
      expect(mail.from).to eq([ApplicationMailer::SENDER_ADDRESS])
    end

    it "sets user as receiver" do
      expect(mail.to).to eq([user.email])
    end

    it "includes username in body" do
      expect(mail.body.encoded).to match(user.username)
    end
  end

  describe ".send_password_reset_email" do
    let(:token) { "abc" }
    let(:user) { build(:user, password_reset_token: token) }
    let(:mail) { UserMailer.password_reset_email(user, token) }

    it "sets subject with i18n convention" do
      expect(mail.subject).to eq(I18n.t("user_mailer.password_reset_email.subject"))
    end

    it "sets sender to default" do
      expect(mail.from).to eq([ApplicationMailer::SENDER_ADDRESS])
    end

    it "sets user as receiver" do
      expect(mail.to).to eq([user.email])
    end

    it "includes password reset link in body" do
      url = /https\:\/\/retiqueta.com\/password_resets\?token\=abc/
      expect(mail.body.raw_source).to match(url)
    end
  end
end
