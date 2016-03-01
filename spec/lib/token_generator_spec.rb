require 'rails_helper'
require 'token_generator'

RSpec.describe TokenGenerator do
  let(:subject) { TokenGenerator.new(User, :password_reset_token) }

  describe "#digest" do
    it "relies on OpenSSL::HMAC.hexdigest to produce a digest" do
      allow(OpenSSL::HMAC)
        .to receive(:hexdigest)
        .with(OpenSSL::Digest.new("SHA256"), subject.send(:key), "raw")
        .and_return("enc")

      expect(subject.digest("raw")).to eq("enc")
    end
  end

  describe "#generate" do
    before do
      allow(subject).to receive(:friendly_token).and_return("raw1", "raw2")
      allow(OpenSSL::HMAC).to receive(:hexdigest).and_return("enc1", "enc2")
    end

    it "returns raw and encoded tokens" do
      expect(subject.generate).to eq(["raw1", "enc1"])
    end

    it "makes sure token is unique" do
      create(:user, password_reset_token: "enc1")
      expect(subject.generate).to eq(["raw2", "enc2"])
    end
  end
end
