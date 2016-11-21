class V1::FulfillmentsController < ApplicationController

  def update
    ::Fulfillments::Update.call(user_id: user_id,
                              fulfillment_id: params[:id],
                              data: update_product_params)
    render json: {}, status: 204
  end

  private

  def update_product_params
    params.require(:data).permit(:type, attributes: [:status])
  end


end
