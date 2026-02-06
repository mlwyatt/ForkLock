class CreateSessions < ActiveRecord::Migration[7.1]
  def change
    create_table :sessions do |t|
      t.string :code
      t.integer :status, default: 0
      t.datetime :expires_at

      t.timestamps
    end

    add_index :sessions, :code, unique: true
  end
end
