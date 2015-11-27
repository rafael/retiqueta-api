class V1::Users::ProductsController < ApplicationController

  def index
    outcome = ::Users::ReadProducts.call(params)
    render json: outcome.success_result, each_serializer: ProductSerializer, include: filtered_include, status: 200
  end

  private

  def filtered_include
    (params[:include] || "").split(",").find_all { |filter| ['product_pictures', 'user'].include?(filter)  }
  end
end
