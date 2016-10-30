class V1::ProductsController < ApplicationController
  # For now only track this controller, tracking all the others is too
  # expensive
  before_action do |controller|
    if user_id
      begin
        action = controller.request.params['action']
        controller_name = controller.request.params['controller']
        method_name = controller.request.method
        params_to_mixpanel = { action: action,
                               controller: controller_name,
                               method: method_name
                             }

        mixpanel_event = 'api_request'
        MixpanelDelayedTracker.perform_later(user_id,
                                             mixpanel_event,
                                             params_to_mixpanel)
      rescue
        Librato.increment 'system.mixpanel.failure'
      end
    end
  end

  def search
    outcome = ::Products::Search.call(params.merge(user_id: user_id))
    render json: outcome.success_result,
           each_serializer: ProductSerializer,
           include: filtered_include,
           status: 200
  end

  def index
    outcome = ::Products::Timeline.call(params.merge(user_id: user_id))
    render json: outcome.success_result, each_serializer: ProductSerializer, include: filtered_include, status: 200
  end

  def timeline
    outcome = ::Products::Timeline.call(params.merge(user_id: user_id))
    render json: outcome.success_result, each_serializer: ProductSerializer, include: filtered_include, status: 200
  end

  def show
    outcome = ::Products::Read.call(user_id: user_id, id: params[:id])
    render json: outcome.success_result, each_serializer: ProductSerializer, include: filtered_include, status: 200
  end

  def create
    outcome = ::Products::Create.call(user_id:  user_id, data: create_or_update_product_params)
    render json: outcome.success_result, serializer: ProductSerializer, status: 201
  end

  def update
    outcome = ::Products::Update.call(user_id: user_id, id: params[:id], data: create_or_update_product_params)
    render json: {}, status: 204
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

  def create_or_update_product_params
    params.require(:data).permit(:type, attributes: allowed_product_attributes)
  end

  def allowed_product_attributes
    [
      :category,
      :title,
      :description,
      :original_price,
      :price,
      :size,
      :location,
      :lat_lon,
      pictures: []
    ]
  end
end
