require 'ostruct'

class V1::TimelineController < ApplicationController
  def index
    outcome = Timeline::Index.call(params.merge(user_id: current_user.uuid))
    render json: outcome.success_result,
           each_serializer: CardSerializer,
           status: 200
  end
end
