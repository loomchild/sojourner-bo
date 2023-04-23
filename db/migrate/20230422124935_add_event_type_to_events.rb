class AddEventTypeToEvents < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :type_id, :string
  end
end
