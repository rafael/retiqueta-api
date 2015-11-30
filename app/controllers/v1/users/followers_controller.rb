require 'ostruct'

class V1::Users::FollowersController < ApplicationController
  def index
    outcome = ::Users::Followers.call(params)
    render json: outcome.success_result,
           each_serializer: FollowerSerializer,
           current_user: current_user,
           status: 200
  end
end
