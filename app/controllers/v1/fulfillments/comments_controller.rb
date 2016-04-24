class V1::Fulfillments::CommentsController < ApplicationController

  before_filter :current_user_can_comment

  def index
    outcome = ::Fulfillments::CommentsIndex.call(params)
    render json: outcome.success_result, each_serializer: TextCommentSerializer, status: 200
  end

  def create
    outcome = ::Fulfillments::CreateComment.call(user_id:  user_id,
                                                 fulfillment_id: params[:fulfillment_id],
                                                 data: create_comments_params)
    render json: outcome.success_result, serializer: TextCommentSerializer, status: 201
  end

  def destroy
    ::Fulfillments::DestroyComment.call(user_id:  user_id,
                                        fulfillment_id: params[:fulfillment_id],
                                        id: params[:id])
    render json: {}, status: 204
  end

  private

  def create_comments_params
    params.require(:data).permit(:type,
                                 attributes: [:text])
  end

  def current_user_can_comment
    fulfillment = Fulfillment.find_by_uuid(params[:fulfillment_id])
    unless fulfillment
      fail(ApiError::NotFound, I18n.t('fulfillments.errors.not_found'))
    end

    if fulfillment.order.user != current_user &&
       !fulfillment.order.sellers.include?(current_user)
      fail(ApiError::NotFound, I18n.t('fulfillments.errors.not_found'))
    end
  end
end
