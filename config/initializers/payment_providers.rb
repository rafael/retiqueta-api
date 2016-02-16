# Module that defines all payment providers SDK's
module PaymentProviders
  module_function def mp_ve
    @mp_ve ||= MercadoPago.new(
      Rails.application.secrets.mercado_pago_ve_access_token
    )
  end
end
