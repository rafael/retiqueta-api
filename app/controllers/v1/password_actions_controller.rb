class V1::PasswordActionsController < ApplicationController
  def send_reset
    ::PasswordActions::SendReset.call(data: send_password_reset_params)
    render json: true, status: 204
  end

  def reset
    ::PasswordActions::Reset.call(data: reset_password_params)
    render json: true, status: 204
  end

  private

  def send_password_reset_params
    params.require(:data).permit(:type, attributes: [:email])
  end

  def reset_password_params
    params.require(:data).permit(:type, attributes: [:password, :token])
  end
end
