class ApplicationController < ActionController::API
  rescue_from ApiError::BaseError, with: :render_error

  def render_error(error)
    render json: error, status: error.status
  end

  before_action do |controller|
    if user_id
      begin
        action = controller.request.params['action']
        controller_name = controller.request.params['controller']
        method_name = controller.request.method
        params_to_mixpanel = { action: action,
                               controller: controller_name,
                               method: method_name
                             }

        mixpanel_event = 'api_request'
        MixpanelDelayedTracker.perform_later(user_id,
                                             mixpanel_event,
                                             params_to_mixpanel)
      rescue
        Librato.increment 'system.mixpanel.failure'
      end
    end
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
