class OpsController < ApplicationController
  def status
    render json: { status: "testing" }, status: :ok
  end

  def ionic_webhook
    IonicWebhookCallback.create!(payload: params.except(:controller, :action).to_json)
    render json: {}, status: :ok
  end

  def mandrill_inbound_webhook
    ::Webhooks::MandrillInbound.call(params)
    render json: {}, status: :ok
  end
end
