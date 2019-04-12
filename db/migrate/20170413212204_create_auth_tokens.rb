class CreateAuthTokens < ActiveRecord::Migration[4.2]
  def change
    create_table :auth_tokens do |t|
      t.datetime :expiration_date
      t.text :token
      t.string :member_ref

      t.timestamps null: false
    end
  end
end
