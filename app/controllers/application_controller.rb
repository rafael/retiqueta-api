class ApplicationController < ActionController::API
  rescue_from ApiError::BaseError, with: :render_error

  def render_error(error)
    render json: error, status: error.status
  end

  protected

  def authorize_user!
    user_id = params[:id] || params[:user_id]
    if request.headers['X-Authenticated-Userid'] != user_id
      raise ApiError::Unauthorized.new(I18n.t("errors.messages.unauthorized"))
    end
  end

  def user_id
    @user_id ||= request.headers['X-Authenticated-Userid']
  end

  def current_user
    @user ||= User.find_by_uuid(user_id)
  end
end
