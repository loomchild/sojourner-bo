class CreateFavourites < ActiveRecord::Migration[7.0]
  def change
    create_table :favourites do |t|
      t.references :conference, type: :string, null: false, foreign_key: true
      t.references :user, type: :string, null: false, foreign_key: true
      t.references :event, type: :string, null: false, foreign_key: true

      t.timestamps
    end
  end
end
