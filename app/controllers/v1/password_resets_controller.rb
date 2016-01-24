class V1::PasswordResetsController < ApplicationController
  def create
    ::PasswordResets::Create.call(data: create_password_reset_params )
    render json: true, status: 204
  end

  def update
    ::PasswordResets::Update.call(data: update_password_params )
    render json: true, status: 204
  end

  private

  def create_password_reset_params
    params.require(:data).permit(:type, attributes: [:email])
  end

  def update_password_params
    params.require(:data).permit(:type, attributes: [:password, :token])
  end
end
