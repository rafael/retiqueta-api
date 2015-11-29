class V1::Products::CommentsController < ApplicationController

  def index
    outcome = ::Products::CommentsIndex.call(params)
    render json: outcome.success_result, each_serializer: TextCommentSerializer, status: 200
  end

  def create
    outcome = ::Products::CreateComment.call(user_id:  user_id,
                                              product_id: params[:product_id],
                                              data: create_comments_params)
    render json: outcome.success_result, serializer: TextCommentSerializer, status: 201
  end

  def destroy
    ::Products::CommentDestroy.call(user_id:  user_id, id: params[:id])
    render json: {}, status: 204
  end

  private

  def create_comments_params
    params.require(:data).permit(:type,
                                 attributes: [:text])
  end
end
