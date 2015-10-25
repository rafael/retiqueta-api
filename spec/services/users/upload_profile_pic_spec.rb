require 'rails_helper'
require 'active_support'

RSpec.describe Users::UploadProfilePic, type: :model do
  describe ".call" do
    let(:user) { create(:user) }
    let(:valid_profile_pic) {
      {
        id: user.uuid,
        data: {
          type: "users",
          attributes: {
            pic: {
              content_type: "image/jpeg",
              filename: "watchmen.jpg",
              content: Base64.encode64(File.open(Rails.root.join("spec/fixtures/watchmen.jpg")) { |io| io.read })
            }
          }
        }
      }
    }

    it "uploads picture to amazon when attributes ara valid" do
      VCR.use_cassette('user/uploading_pic', match_requests_on: [:host, :method]) do
        service_result = Users::UploadProfilePic.call(valid_profile_pic)
        expect(service_result.success_result).to eq(user)
      end
    end
  end
end
