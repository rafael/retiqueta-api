class V1::ProductsController < ApplicationController

  def search
    outcome = ::Products::Search.call(params)
    render json: outcome.success_result, each_serializer: ProductSerializer, status: 200
  end

  def create
    outcome = ::Products::Create.call(user_id:  user_id, data: create_product_params)
    render json: outcome.success_result, serializer: ProductSerializer, status: 201
  end

  private

  def create_product_params
    params.require(:data).permit(:type,
                                 attributes: [:category,
                                              :title,
                                              :description,
                                              :original_price,
                                              :price,
                                              pictures: []])
  end
end
