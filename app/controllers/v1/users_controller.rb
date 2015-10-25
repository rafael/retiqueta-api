class V1::UsersController < ApplicationController

  before_action :authorize_user!

  def show
    outcome = ::Users::Read.call(id:  params[:id])
    render json: outcome.success_result, serializer: UserSerializer, status: 200
  end

  def update
    ::Users::Update.call(id:  params[:id], data: user_params)
    render json: true, status: 204
  end

  def upload_profile_pic
    outcome = ::Users::UploadProfilePic.call(id:  params[:user_id], data: user_params)
    render json: outcome.success_result, serializer: UserSerializer, status: 200
  end

  private



  def user_params
    params.require(:data).permit(:type,
                                 attributes: [:first_name,
                                              :last_name,
                                              :website,
                                              :bio,
                                              :country])
  end

  def upload_pic_params
    params.require(:data).permit(:type,
                                 attributes: [pic: [:filename, :content, :content_type]])
  end
end
