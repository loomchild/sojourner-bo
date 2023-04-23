class AddSubtitleToEvents < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :subtitle, :string
  end
end
