class V1::ProductsController < ApplicationController

  def search
    outcome = ::Products::Search.call(params)
    render json: outcome.success_result,
           each_serializer: ProductSerializer,
           include: filtered_include,
           status: 200
  end

  def index
    outcome = ::Products::Index.call(params)
    render json: outcome.success_result, each_serializer: ProductSerializer, include: filtered_include, status: 200
  end

  def show
    outcome = ::Products::Read.call(user_id: user_id, id: params[:id])
    render json: outcome.success_result, each_serializer: ProductSerializer, include: filtered_include, status: 200
  end

  def create
    outcome = ::Products::Create.call(user_id:  user_id, data: create_product_params)
    render json: outcome.success_result, serializer: ProductSerializer, status: 201
  end

  def destroy
    ::Products::Destroy.call(user_id:  user_id, id: params[:id])
    render json: {}, status: 204
  end

  def like
    ::Products::Like.call(user_id: user_id, product_id: params[:product_id])
    render json: {}, status: 204
  end

  def unlike
    ::Products::Unlike.call(user_id: user_id, product_id: params[:product_id])
    render json: {}, status: 204
  end

  private

  def filtered_include
    (params[:include] || "").split(",").find_all { |filter| ['product_pictures', 'user', 'comments'].include?(filter)  }
  end

  def create_product_params
    params.require(:data).permit(:type,
                                 attributes: [:category,
                                              :title,
                                              :description,
                                              :original_price,
                                              :price,
                                              :size,
                                              pictures: []])
  end
end
