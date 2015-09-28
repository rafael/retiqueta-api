class OpsController < ApplicationController
  def status
    render json: { status: "hola joha" }, status: :ok
  end

end
