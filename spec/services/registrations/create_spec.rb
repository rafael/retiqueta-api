require 'rails_helper'

RSpec.describe Registrations::Create, type: :model do
  describe ".save" do
    let(:params) { {
                     data: {
                       type: "users",
                       attributes: {
                         name: "Rafael Chacon",
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
      expect(service_result.outcome).to eq(User.last)
    end

    it "delegates errors from user object" do
      params[:data][:attributes][:password] = "12"
      service_result = Registrations::Create.call(params)
      expect(service_result).to_not be_valid
    end
  end
end
