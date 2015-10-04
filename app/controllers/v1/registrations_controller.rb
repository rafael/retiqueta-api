class V1::RegistrationsController < ApplicationController
  def create
    outcome = ::Registrations::Create.call(data:  user_params )
    if outcome.valid?
      render json: outcome.success_result, serializer: UserSerializer, status: 201
    else
      render json: outcome.failure_result.to_json, status: 422
    end
  end

  private

  def user_params
     params.require(:data).permit(:type, attributes: [:name, :email, :username, :password ])
  end
end
