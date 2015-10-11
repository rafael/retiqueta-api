class V1::AuthenticatesController < ApplicationController
  def create
    outcome = ::Authenticate::Create.call(authenticate_params)
    if outcome.valid?
      render json: outcome.success_result, status: outcome.status
    else
      render json: outcome.failure_result.to_json, status: 400
    end
  end

  private

  def authenticate_params
     params.permit(:login, :password)
  end

end
