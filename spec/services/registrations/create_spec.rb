require 'rails_helper'

RSpec.describe Registrations::Create, type: :model do
  include ActiveJob::TestHelper

  describe ".call" do
    let(:params) do
      {
        data: {
          type: "users",
          attributes: {
            password: "123456",
            email: "rafaelchacon@gmail.com",
            username: "rafael"
          }
        }
      }
    end

    context "when all the required fields are provided" do
      let(:service_result) { Registrations::Create.call(params) }

      it "saves the user" do
        expect(service_result).to be_valid
      end

      it "updates service result to be newly created user" do
        expect(service_result.success_result).to eq(User.last)
      end

      it "enqueues a welcome email for the user" do
        service_result = nil
        allow(UserMailer).to receive(:signup_email).and_call_original

        expect {
          service_result = Registrations::Create.call(params)
        }.to change(enqueued_jobs, :size).by(1)

        expect(UserMailer)
          .to have_received(:signup_email)
          .with(service_result.success_result)
      end
    end

    it "delegates errors from user object" do
      params[:data][:attributes][:password] = "12"
      expect do
        Registrations::Create.call(params)
      end.to raise_error(ApiError::FailedValidation)
    end
  end
end
