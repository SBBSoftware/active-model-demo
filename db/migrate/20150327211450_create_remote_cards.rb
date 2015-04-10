class CreateRemoteCards < ActiveRecord::Migration
  def change
    create_table :remote_cards do |t|
      t.belongs_to :remote_wallet, index: true
      t.string :card_token, null: false
      t.string :card_type
      t.date :expiration_date
      t.string :card_number, null: false
    end
    add_index :remote_cards, :card_token, unique: true
    add_foreign_key :remote_cards, :remote_wallets
  end
end
