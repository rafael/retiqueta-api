require 'rails_helper'

RSpec.describe Registrations::Create, type: :model do
  describe ".save" do
    let(:params) { {
                     data: {
                       type: "users",
                       attributes: {
                         password: "123456",
                         email: "rafaelchacon@gmail.com",
                         username: "rafael"
                       }
                     }
                   }
    }

    it "saves an user when all the required fields are provided" do
      service_result = Registrations::Create.call(params)
      expect(service_result).to be_valid
      expect(service_result.success_result).to eq(User.last)
    end

    it "delegates errors from user object" do
      params[:data][:attributes][:password] = "12"
      expect do
        Registrations::Create.call(params)
      end.to raise_error(ApiError::FailedValidation)
    end
  end
end
