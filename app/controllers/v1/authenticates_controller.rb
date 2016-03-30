class V1::AuthenticatesController < ApplicationController
  def create
    outcome = ::Authenticate::Create.call(authenticate_params)
    render json: outcome.success_result, status: 200
  end

  def refreh_token
    outcome = ::Authenticate::RefreshToken.call(refresh_token_params)
    render json: outcome.success_result, status: outcome.status
  end

  def fb_connect
    outcome = ::Authenticate::FacebookConnect.call(fb_connect_params)
    render json: outcome.success_result, status: outcome.status
  end

  private

  def authenticate_params
    params.permit(:login, :password, :client_id)
  end

  def refresh_token_params
    params.permit(:refresh_token, :client_id)
  end

  def fb_connect_params
    params.permit(:token, :expires_in)
  end
end
