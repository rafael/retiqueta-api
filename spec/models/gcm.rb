require 'rails_helper'

RSpec.describe GCM do
  describe "Configuration" do

    it "Configure server_key" do
      GCM.config.server_key = 'AIzaSyAtoaJOKbAFTV47hTgzxCRd8vLmqhvgTEk'
      instance = GCM.new
      expect(instance.server_key).to eq('AIzaSyAtoaJOKbAFTV47hTgzxCRd8vLmqhvgTEk')
    end

    it "Thow error when is not valid" do
      expect { GCM.new({ to: 'test'}).valid? }.to raise_error(ApiError::FailedValidation)
      expect { GCM.new({ data: 'test' }).valid? }.to raise_error(ApiError::FailedValidation)
    end

    it "Faraday configure headers" do
      VCR.use_cassette('GCM/GCM_configure_authotization') do
        gcm = GCM.new({to: 'test', data: 'test'})
        result = gcm.notificate
        expect(result.env.request_headers).to include({'Authorization': "key=#{GCM.server_key}"})
      end
    end
  end


  describe "Using the api" do
    it "Todo" do

    end
  end
end
