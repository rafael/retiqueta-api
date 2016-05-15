require 'rails_helper'

RSpec.describe 'Payouts', type: :request do
  let(:user) { create(:user, password: '123456') }
  let(:sale) { create(:sale, user: user, amount: 100) }

  let(:params) do
    {
      user_id: user.uuid,
      data: {
        type: 'payouts',
        attributes: {
          amount: 100.0
        }
      }
    }
  end

  it 'shows payouts' do
    sale
    post '/v1/payouts', params, 'X-Authenticated-Userid' => user.uuid
    get '/v1/payouts', {}, 'X-Authenticated-Userid' => user.uuid
    expect(response.status).to eq(200)
    expect(json['data'].first['attributes']['amount']).to eq(100.0)
    expect(json['data'].first['attributes']['status']).to eq('processing')
    expect(json['data'].first['attributes']['created_at']).to eq(I18n.l(Payout.last.created_at.to_date, format: :default))
  end

  it 'creates a payout' do
    sale
    post '/v1/payouts', params, 'X-Authenticated-Userid' => user.uuid
    expect(response.status).to eq(201)
    expect(json['data']['attributes']['amount']).to eq(100.0)
    expect(json['data']['attributes']['status']).to eq('processing')
    expect(json['data']['attributes']['created_at']).to eq(I18n.l(Payout.last.created_at.to_date, format: :default))
  end
end
