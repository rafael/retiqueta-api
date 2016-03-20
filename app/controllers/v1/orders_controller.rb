class V1::OrdersController < ApplicationController
  def index
    outcome = ::Orders::Index.call(params.merge(user_id: user_id))
    render json: outcome,
           each_serializer: OrderSerializer,
           include: filtered_include,
           status: 200
  end

  def show
    outcome = ::Orders::Read.call(params.merge(user_id: user_id))
    render json: outcome,
           serializer: OrderSerializer,
           include: filtered_include,
           status: 200
  end

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

  def filtered_include
    (params[:include] || '').split(',').find_all { |filter| %w(line_items.product.product_pictures line_items.product line_items fulfillment user).include?(filter) }
  end
end
