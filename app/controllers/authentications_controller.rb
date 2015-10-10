class AuthenticationsController < ApplicationController
  def create
    if params[:login].blank? || params[:password].blank?
      return render :json => {}, :status => 400
    end
    user =  User.find_by_email(params[:login])
    user ||= User.find_by_username(params[:login])

    if user.valid_password?(params[:password])
      data = {
        user_id: user.id
      }
      render :json => data, :status => 201
    else
      render :json => {}, :status => 401
    end
  end
end
