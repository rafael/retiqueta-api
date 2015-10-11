class OpsController < ApplicationController
  def status
    render json: { status: "testing" }, status: :ok
  end
end
