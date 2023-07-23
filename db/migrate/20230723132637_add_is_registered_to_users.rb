class AddIsRegisteredToUsers < ActiveRecord::Migration[7.0]
  def change
    remove_column :users, :email, :string
    add_column :users, :is_registered, :boolean, null: false, default: false

    change_table(:conference_users) { |t| t.timestamps }
  end
end
