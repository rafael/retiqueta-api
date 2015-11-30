require 'ostruct'

class V1::Users::FollowingController < ApplicationController
  def index
    outcome = ::Users::Following.call(params)
    render json: outcome.success_result,
           status: 200,
           each_serializer: FollowerSerializer,
           current_user: current_user
  end
end
