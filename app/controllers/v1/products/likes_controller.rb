class V1::Products::LikesController < ApplicationController
  def index
    outcome = ::Products::ReadLikes.call(params)
    render json: outcome.success_result, each_serializer: PublicUserSerializer, status: 200
  end
end
