# Module that defines all payment providers SDK's
require 'mercadopago.rb'

module PaymentProviders
  ML_VE_NAME = 'mercadopago_ve'
  module_function def mp_ve
    @mp_ve ||= MercadoPago.new(
      Rails.application.secrets.mercado_pago_ve_access_token
    )
  end
end
