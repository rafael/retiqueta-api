require 'rails_helper'

RSpec.describe PasswordResets::Update, type: :model do
  let(:user) { create(:user, password_reset_token: token, password_reset_sent_at: token_sent_at) }
  let(:email) { "john.smith@gmail.com" }
  let(:subject) { PasswordResets::Update.new(params) }
  let(:token) { "abc" }
  let(:token_sent_at) { DateTime.now.utc }
  let(:password) { "password" }

  let(:params) do
    {
      data: {
        type: "users",
        attributes: {
          token: user.password_reset_token,
          password: password
        }
      }
    }
  end

  describe "#generate_result!" do
    it "updates user password" do
      subject.generate_result!
      user.reload
      expect(user.valid_password?(password)).to eq(true)
    end

    it "unsets password reset token" do
      subject.generate_result!
      user.reload
      expect(user.password_reset_token).to be_nil
    end

    it "unsets password reset token sent date" do
      subject.generate_result!
      user.reload
      expect(user.password_reset_sent_at).to be_nil
    end

    it "raises a validation error when password is not valid" do
      params[:data][:attributes][:password] = "pw"

      expect {
        subject.generate_result!
      }.to raise_error(ApiError::FailedValidation)
    end
  end

  describe "#initialize" do
    it "raises error when resource type is not present" do
      params[:data][:type] = ""

      expect {
        described_class.new(params)
      }.to raise_error(ApiError::FailedValidation, /type/i)
    end

    it "raises error when password attr is not present" do
      params[:data][:attributes][:password] = ""

      expect {
        described_class.new(params)
      }.to raise_error(ApiError::FailedValidation, /password/i)
    end

    it "raises error when token attr is not present" do
      params[:data][:attributes][:token] = ""

      expect {
        described_class.new(params)
      }.to raise_error(ApiError::FailedValidation, /token/i)
    end

    it "raises error when resource type is not users" do
      wrong_type = "wrong_type"
      params[:data][:type] = wrong_type
      error_message = I18n.t("errors.invalid_type", type: wrong_type, resource_type: "users")

      expect {
        described_class.new(params)
      }.to raise_error(ApiError::FailedValidation, error_message)
    end

    it "raises error when token is not valid" do
      params[:data][:attributes][:token] = "xxx"
      error_message = I18n.t("errors.invalid_password_reset_token")

      expect {
        described_class.new(params)
      }.to raise_error(ApiError::FailedValidation, error_message)
    end

    context "when token expired" do
      let(:token_sent_at) { 2.hours.ago.utc }

      it "raises error" do
        error_message = I18n.t("errors.invalid_password_reset_token")

        expect {
          described_class.new(params)
        }.to raise_error(ApiError::FailedValidation, error_message)
      end
    end
  end
end
