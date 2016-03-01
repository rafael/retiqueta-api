class V1::OrdersController < ApplicationController

  def create
    outcome = ::Orders::Create.call(user_id: user_id, data: order_params)
    render json: outcome.success_result,
           serializer: OrderSerializer,
           status: 201
  end

  private

  def order_params
    params.require(:data).permit(:type,
                                 attributes: [:shipping_address,
                                              payment_data: [:token,
                                                             :payment_method_id],
                                              line_items: [:product_type,
                                                           :product_id]])
  end
end
