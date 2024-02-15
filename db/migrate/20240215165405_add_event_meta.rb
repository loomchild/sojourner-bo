class AddEventMeta < ActiveRecord::Migration[7.1]
  def change
    add_column :events, :meta, :jsonb, null: false, default: {}
  end
end
