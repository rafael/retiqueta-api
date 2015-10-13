class V1::AuthenticatesController < ApplicationController
  def create
    outcome = ::Authenticate::Create.call(authenticate_params)
    if outcome.valid?
      render json: outcome.success_result, status: outcome.status
    else
      render json: outcome.failure_result.to_json, status: outcome.status
    end
  end

  def refreh_token
    outcome = ::Authenticate::RefreshToken.call(refresh_token_params)
    if outcome.valid?
      render json: outcome.success_result, status: outcome.status
    else
      render json: outcome.failure_result.to_json, status: 400
    end
  end

  private

  def authenticate_params
     params.permit(:login, :password, :client_id)
  end

  def refresh_token_params
    params.permit(:refresh_token, :client_id)
  end

end
