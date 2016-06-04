class V1::Users::PushTokensController < ApplicationController

  before_action :authorize_user!

  def create
    ::Users::CreatePushToken.call(user_id: user_id, data: create_push_token_params)
    render json: {},
           status: 201
  end

  private

  def create_push_token_params
    params.require(:data).permit(:type,
                                 attributes: [:environment,
                                              :token,
                                              :device_id,
                                              :platform])
  end
end
