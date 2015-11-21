class V1::UsersController < ApplicationController

  before_action :authorize_user!, only: [:update, :upload_profile_pic]

  def show
    outcome = ::Users::Read.call(id:  params[:id])
    render json: outcome.success_result, serializer: user_serializer, status: 200, image_size: request.headers['image-size']
  end

  def update
    ::Users::Update.call(id:  params[:id], data: user_params)
    render json: true, status: 204
  end

  def upload_profile_pic
    outcome = ::Users::UploadProfilePic.call(id:  params[:user_id], data: upload_pic_params)
    render json: outcome.success_result, serializer: UserSerializer, status: 201
  end

  def follow
    ::Users::Follow.call(follower_id:  user_id, followed_id: params[:user_id])
    render json: true, status: 204
  end

  def unfollow
    ::Users::Unfollow.call(follower_id:  user_id, followed_id: params[:user_id])
    render json: true, status: 204
  end

  private

  def user_serializer
    if params[:id] == user_id
      UserSerializer
    else
      PublicUserSerializer
    end
  end

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
