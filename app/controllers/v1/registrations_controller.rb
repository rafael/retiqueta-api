class V1::RegistrationsController < ApplicationController
  def create
    @user = User.new(user_params[:attributes])
    if @user.valid? && @user.save
      render json: @user, serializer: UserSerializer, status: 201
    else
      render json: @user, status: 422
    end
  end

  private

  def user_params
     params.require(:data).permit(:type, attributes: [:name, :email, :username, :password ])
  end
end
