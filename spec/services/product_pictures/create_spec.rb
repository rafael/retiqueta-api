require 'rails_helper'
require 'active_support'

RSpec.describe ProductPictures::Create, type: :model do
  describe ".call" do
    let(:user) { create(:user) }
    let(:valid_product_picture) {
      {
        user_id: user.uuid,
        data: {
          type: "product_pictures",
          attributes: {
            position: 0,
            pic: {
              content_type: "image/jpeg",
              filename: "watchmen.jpg",
              content: Base64.encode64(File.open(Rails.root.join("spec/fixtures/watchmen.jpg")) { |io| io.read })
            },
          }
        }
      }
    }

    it "uploads picture to amazon when attributes ara valid" do
      VCR.use_cassette('product/uploading_pic', match_requests_on: [:host, :method]) do
        expect do
          service_result = described_class.call(valid_product_picture)
          expect(service_result.success_result.position).to eq(0)
          expect(service_result.success_result.user_id).to eq(user.uuid)
        end.to change { ProductPicture.count}.by(1)
      end
    end
  end
end
