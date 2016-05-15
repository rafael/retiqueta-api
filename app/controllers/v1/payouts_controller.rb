class V1::PayoutsController < ApplicationController
  def index
    outcome = Payout.where(user_id: user_id).all
    render json: outcome,
           each_serializer: PayoutSerializer,
           status: 200
  end

  def create
    outcome = ::Payouts::Create.call(params.merge(user_id: user_id))
    render json: outcome,
           serializer: PayoutSerializer,
           status: 201
  end
end
