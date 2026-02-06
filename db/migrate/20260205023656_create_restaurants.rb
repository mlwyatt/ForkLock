class CreateRestaurants < ActiveRecord::Migration[7.1]
  def change
    create_table :restaurants do |t|
      t.string :name
      t.string :cuisine
      t.decimal :rating
      t.integer :price_level
      t.string :distance
      t.text :description
      t.string :image_url

      t.timestamps
    end
  end
end
