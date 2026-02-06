class CreateParticipants < ActiveRecord::Migration[7.1]
  def change
    create_table :participants do |t|
      t.belongs_to :session, null: false
      t.string :name
      t.string :token
      t.datetime :completed_at

      t.timestamps
    end

    add_index :participants, :token, unique: true
  end
end
