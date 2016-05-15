require 'rails_helper'

RSpec.describe Payouts::Create, type: :model do
  let(:seller) { create(:user) }
  let(:params) do
    {
      user_id: seller.uuid,
      data: {
        type: 'payouts',
        attributes: {
          amount: 100
        }
      }
    }
  end

  it 'allows to request a payout when amount is available' do
    create(:sale, user: seller, amount: 100)
    payout = described_class.call(params)
    expect(payout.user).to eq(seller)
    expect(payout.amount).to eq(100)
    expect(payout.status).to eq('processing')
  end

  it 'needs to be greater than 0' do
    expect do
      invalid_params = params
      invalid_params[:data][:attributes][:amount] = 0
      described_class.call(params)
    end.to raise_error(ApiError::FailedValidation,
                       'Amount must be greater than 0')
  end

  it 'needs available funds' do
    expect do
      described_class.call(params)
    end.to raise_error(ApiError::FailedValidation,
                       "Sorry, you don't have enough money to request this payout")
  end

  it 'takes into consideration previous payouts' do
    create(:sale, user: seller, amount: 100)
    described_class.call(params)
    expect do
      described_class.call(params)
    end.to raise_error(ApiError::FailedValidation,
                       "Sorry, you don't have enough money to request this payout")
  end
end
