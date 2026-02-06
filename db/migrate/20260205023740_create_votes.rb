class CreateVotes < ActiveRecord::Migration[7.1]
  def change
    create_table :votes do |t|
      t.belongs_to :participant, null: false
      t.belongs_to :restaurant, null: false
      t.boolean :liked, null: false, default: false

      t.timestamps
    end

    add_index :votes, %i[participant_id restaurant_id], unique: true
  end
end
