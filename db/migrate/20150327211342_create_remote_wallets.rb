class CreateRemoteWallets < ActiveRecord::Migration
  def change
    create_table :remote_wallets do |t|
      t.string :wallet_token, null: false
      t.string :first_name
      t.string :last_name
      t.string :email, null: false
      t.integer :age
      t.string :account_number
    end
    add_index :remote_wallets, :wallet_token, unique: true
  end
end
