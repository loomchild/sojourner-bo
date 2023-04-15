class CreateConferenceUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :conference_users do |t|
      t.references :conference, type: :string, null: false, foreign_key: true
      t.references :user, type: :string, null: false, foreign_key: true
    end
  end
end
