class V1::ProductPicturesController < ApplicationController

  def create
    outcome = ::ProductPictures::Create.call(user_id:  user_id, data: create_product_picture_params)
    render json: outcome.success_result, serializer: ProductPictureSerializer, status: 201
  end

  private

  def create_product_picture_params
    params.require(:data).permit(:type,
                                 attributes: [:position, pic: [:filename, :content, :content_type]])
  end
end
