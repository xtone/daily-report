class CreateApiTokens < ActiveRecord::Migration[8.0]
  def change
    create_table :api_tokens do |t|
      t.integer :user_id, null: false
      t.string :token_digest, null: false
      t.string :name, default: 'Default'
      t.datetime :last_used_at
      t.datetime :revoked_at

      t.timestamps
    end

    add_index :api_tokens, :token_digest, unique: true
    add_index :api_tokens, :user_id
    add_foreign_key :api_tokens, :users
  end
end
