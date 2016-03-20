class V1::SalesController < ApplicationController
  def index
    outcome = ::Sales::Index.call(params.merge(user_id: user_id))
    render json: outcome,
           each_serializer: SaleSerializer,
           include: filtered_include,
           status: 200
  end

  def show
    outcome = ::Sales::Read.call(params.merge(user_id: user_id))
    render json: outcome,
           serializer: SaleSerializer,
           include: filtered_include,
           status: 200
  end

  def filtered_include
    (params[:include] || '').split(',').find_all do |filter|
      ['order',
       'order.line_items.product.product_pictures',
       'order.line_items.product',
       'order.line_items',
       'order.fulfillment',
       'order.user'].include?(filter)
    end
  end
end
