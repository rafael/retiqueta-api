require 'ostruct'

class V1::Users::FollowersController < ApplicationController
  def index
    outcome = ::Users::Followers.call(
      params.merge(current_user: current_user,
                   request_context: request_context))
    render json: outcome.success_result.to_json,
           status: 200
  end


  private

  def request_context
    @request_context ||= OpenStruct.new(original_url: env['REQUEST_URI'],
                                        query_parameters: env['rack.request.query_hash'])

  end
end
