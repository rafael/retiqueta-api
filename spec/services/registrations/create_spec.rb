require 'rails_helper'

RSpec.describe Registrations::Create, type: :model do
  include ActiveJob::TestHelper

  describe '.call' do
    let(:params) do
      {
        data: {
          type: 'users',
          attributes: {
            password: '123456',
            email: 'rafaelchacon@gmail.com',
            username: 'rafael'
          }
        }
      }
    end

    context 'when all the required fields are provided' do
      let(:service_result) { Registrations::Create.call(params) }

      it 'saves the user' do
        expect(service_result).to be_valid
      end

      it 'saves the user when there is no username' do
        params_without_password = params
        params_without_password[:data][:attributes][:username] = nil
        params_without_password[:data][:attributes][:email] = 'jose@test.com'
        expect(service_result).to be_valid
        user = User.last
        expect(user.store_fee).to eq(0.2)
        expect(user.username).to include('jose')
      end

      it 'updates service result to be newly created user' do
        expect(service_result.success_result).to eq(User.last)
      end

      it 'enqueues account bootstrap' do
        service_result = nil
        allow(AccountBootstrap).to receive(:perform_later).and_call_original

        expect do
          service_result = Registrations::Create.call(params)
        end.to change(enqueued_jobs, :size).by(3)

        expect(AccountBootstrap)
          .to have_received(:perform_later)
          .with(service_result.success_result)
      end

      it 'enqueues a welcome email for the user' do
        service_result = nil
        allow(UserMailer).to receive(:signup_email).and_call_original

        expect do
          service_result = Registrations::Create.call(params)
        end.to change(enqueued_jobs, :size).by(3)

        expect(UserMailer)
          .to have_received(:signup_email)
          .with(service_result.success_result)
      end

      it 'sets Venezuela as default country' do
        expect(service_result.success_result.country).to eq('VE')
      end
    end

    it 'delegates errors from user object' do
      params[:data][:attributes][:password] = '12'
      expect do
        Registrations::Create.call(params)
      end.to raise_error(ApiError::FailedValidation)
    end
  end
end
