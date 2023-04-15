class CreateConferences < ActiveRecord::Migration[7.0]
  def change
    create_table :conferences, id: :string do |t|
      t.string :name

      t.timestamps
    end
  end
end
