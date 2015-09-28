class OpsController < ApplicationController
  def status
    render json: { status: "test-deploy" }, status: :ok
  end

end
