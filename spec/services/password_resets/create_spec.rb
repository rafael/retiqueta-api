require 'rails_helper'

RSpec.describe PasswordResets::Create, type: :model do
  include ActiveJob::TestHelper

  let(:user) { create(:user, email: email) }
  let(:email) { "john.smith@gmail.com" }
  let(:subject) { PasswordResets::Create.new(params) }
  let(:password_token) { "abc" }
  let(:time_now) { Time.parse("2016-01-01") }

  let(:params) do
    {
      data: {
        type: "users",
        attributes: {
          email: user.email
        }
      }
    }
  end

  describe "#generate_result!" do
    before do
      allow(subject).to receive(:generate_token).and_return(password_token)
      allow(subject).to receive(:current_utc_datetime).and_return(time_now)
    end

    it "updates user with password token" do
      subject.generate_result!
      user.reload
      expect(user.password_reset_token).to eq(password_token)
    end

    it "updates user with time when password reset was requested" do
      subject.generate_result!
      user.reload
      expect(user.password_reset_sent_at).to eq(time_now)
    end

    it "enqueues a reset password email" do
      allow(UserMailer).to receive(:password_reset_email).and_call_original

      expect {
        subject.generate_result!
      }.to change(enqueued_jobs, :size).by(1)

      expect(UserMailer)
        .to have_received(:password_reset_email)
        .with(user)
    end
  end

  describe "#initialize" do
    it "raises error when resource type is not present" do
      params[:data][:type] = ""

      expect {
        described_class.new(params)
      }.to raise_error(ApiError::FailedValidation, /type/i)
    end

    it "raises error when email attr is not present" do
      params[:data][:attributes][:email] = ""

      expect {
        described_class.new(params)
      }.to raise_error(ApiError::FailedValidation, /email/i)
    end

    it "raises error when resource type is not users" do
      wrong_type = "wrong_type"
      params[:data][:type] = wrong_type
      error_message = I18n.t("errors.invalid_type", type: wrong_type, resource_type: "users")

      expect {
        described_class.new(params)
      }.to raise_error(ApiError::FailedValidation, error_message)
    end

    it "raises error when user does not exist" do
      params[:data][:attributes][:email] = "fake@email.com"
      error_message = I18n.t("user.errors.not_found")

      expect {
        described_class.new(params)
      }.to raise_error(ApiError::NotFound, error_message)
    end
  end

  describe "#generate_token" do
    it "generates a token with random number of 36 bytes long" do
      allow(SecureRandom)
        .to receive(:urlsafe_base64)
        .with(36)
        .and_return("abc")

      expect(subject.generate_token).to eq("abc")
    end
  end

  describe "#current_utc_datetime" do
    let(:time_now) { DateTime.now }
    before { allow(DateTime).to receive(:now).and_return(time_now) }

    it "returns current datetime in UTC" do
      expect(subject.current_utc_datetime).to eq(time_now.utc)
    end
  end
end
