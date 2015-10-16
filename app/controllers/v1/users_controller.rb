class V1::UsersController < ApplicationController
  def show
    outcome = ::Users::Read.call(id:  params[:id])
    if outcome.valid?
      render json: outcome.success_result, serializer: UserSerializer, status: 200
    else
      render json: outcome.failure_result.to_json, status: 404
    end
  end

  def upload_profile_pic
    outcome = ::Users::UploadProfilePic.call(id:  params[:user_id], data: user_params)
    if outcome.valid?
      render json: outcome.success_result, serializer: UserSerializer, status: 200
    else
      render json: outcome.failure_result.to_json, status: 400
    end
  end

  private


  def user_params
     params.require(:data).permit(:type, attributes: [pic: [:filename, :content, :content_type]])
  end
end
