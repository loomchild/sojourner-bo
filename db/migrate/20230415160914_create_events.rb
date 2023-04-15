class CreateEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :events, id: :string do |t|
      t.references :conference, type: :string, null: false, foreign_key: true
      t.references :track, null: false, foreign_key: true
      t.string :title
      t.string :abstract
      t.string :description
    end
  end
end
