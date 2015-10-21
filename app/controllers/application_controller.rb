class ApplicationController < ActionController::API
  rescue_from ApiError::BaseError, with: :render_error

  def render_error(error)
    render json: error, status: error.status
  end
end
