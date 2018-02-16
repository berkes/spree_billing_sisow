class CreateSisowTransactions < ActiveRecord::Migration[5.0]
  def change
    create_table :spree_sisow_transactions do |t|
      t.string :transaction_id
      t.string :entrance_code
      t.string :status
      t.string :sha1

      t.timestamps
    end
  end
end
