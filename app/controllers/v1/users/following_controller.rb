require 'ostruct'

class V1::Users::FollowingController < ApplicationController
  def index
    outcome = ::Users::Following.call(
      params.merge(current_user: current_user,
                   request_context: request_context))
    render json: outcome.success_result.to_json,
           status: 200
  end

  private

  def request_context
    @request_context ||= OpenStruct.new(original_url: request.url,
                                        query_parameters: env['rack.request.query_hash'])

  end

end
