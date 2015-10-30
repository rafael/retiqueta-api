require 'rails_helper'

RSpec.describe GCM do
  describe "Configuration" do
    it "Configure server_key" do
      GCM.config.server_key = 'test'
      instance = GCM.new
      expect(instance.server_key).to eq('test')
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
    it "Send without needed data" do
      GCM.new
    end
  end
end
