class SetDefaultPaymentMethodAndProviderToPaymentTransactions < ActiveRecord::Migration
  def self.up
    PaymentTransaction.update_all(payment_method: 'visa',
                                  payment_provider: PaymentProviders::ML_VE_NAME)
  end

  def self.down
    #NOOP
  end
end
