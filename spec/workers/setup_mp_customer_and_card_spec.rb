require 'rails_helper'

RSpec.describe SetupMpCustomerAndCard, type: :job, vcr: true do
  let(:user) { create(:user) }
  let(:token) { '287e6d7899cfb0ee51de5d8bcc12c311' }
  let(:success_payment_response) do
    { 'status' => '201',
      'response' => { 'id' => 2_452_250_355,
                      'card' => {
                        'cardholder' => {
                          'name' => 'Rafael chacon vivas',
                          'identification' => {
                            'number' => '17646706',
                            'type' => 'CI'
                          }
                        }
                      },
                    }
    }
  end

  it 'creates customer and card in mercadopago' do
    expect do
      SetupMpCustomerAndCard.perform_now(user, token, success_payment_response)
    end.to change(MpCustomer, :count).by(1)
    customer = MpCustomer.last
    expect(customer.user_id).to eq(user.uuid)
    expect(customer.payload['cards'].count).to eq(1)
  end
end
