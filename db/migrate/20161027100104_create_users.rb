class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :name
      t.datetime :deleted_at

      ## Database authenticatable
      t.string :email
      t.string :encrypted_password, null: false, default: ""

      ## Rememberable
      t.datetime :remember_created_at

      t.date :began_on

      t.timestamps

      t.index :email, unique: true
    end
  end
end
