class CreateSpeakers < ActiveRecord::Migration[7.0]
  def change
    create_table :speakers do |t|
      t.references :conference, type: :string, null: false, foreign_key: true
      t.string :name
    end
  end
end
