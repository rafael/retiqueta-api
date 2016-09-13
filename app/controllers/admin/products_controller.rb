class Admin::ProductsController < ApplicationController
  before_filter :admin_user!

  def merched_ids
    merched_ids = params[:merched_ids]
    AppClients.redis.del("merched_ids")
    AppClients.redis.lpush("merched_ids", *merched_ids)
    render json: {}, status: 200
  end

  private

  def admin_user!
    if current_user.role != "admin"
      raise ApiError::Unauthorized.new(I18n.t("errors.messages.unauthorized"))
    end
  end
end
