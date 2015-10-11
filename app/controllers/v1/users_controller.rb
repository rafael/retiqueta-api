class V1::UsersController < ApplicationController
  def show
    outcome = ::Users::Read.call(id:  params[:id])
    if outcome.valid?
      render json: outcome.success_result, serializer: UserSerializer, status: 200
    else
      render json: outcome.failure_result.to_json, status: 404
    end
  end
end
