class AddPaymentMethodToPaymentTransactions < ActiveRecord::Migration
  def change
    add_column :payment_transactions, :payment_method, :string, limit: 20
  end
end
