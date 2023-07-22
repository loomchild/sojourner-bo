class AddStartDateAndEndDateToConferences < ActiveRecord::Migration[7.0]
  def change
    add_column :conferences, :start_date, :date
    add_column :conferences, :end_date, :date
  end
end
