class AddPaymentProviderToPaymentTransactions < ActiveRecord::Migration
  def change
    add_column :payment_transactions, :payment_provider, :string, limit: 60
  end
end
