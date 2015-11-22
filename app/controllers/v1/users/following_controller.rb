class V1::Users::FollowingController < ApplicationController
  def index
    outcome = ::Users::Following.call(params)
    render json: outcome.success_result, each_serializer: FollowerSerializer, status: 200
  end
end
