class AddTransactionTypeToSisowTransactions < ActiveRecord::Migration[5.0]
  def change
    add_column :spree_sisow_transactions, :transaction_type, :string
  end
end
