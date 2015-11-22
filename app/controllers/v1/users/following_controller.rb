class V1::Users::FollowingController < ApplicationController
  def index
    outcome = ::Users::Following.call(params.merge(current_user: current_user))
    render json: outcome.success_result.to_json,
           status: 200
  end
end
