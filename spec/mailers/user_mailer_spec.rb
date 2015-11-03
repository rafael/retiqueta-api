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
end
