class AddContentToEvents < ActiveRecord::Migration[7.0]
  def change
    add_column :events,
               :content,
               :virtual,
               type: :string,
               as: "coalesce(title,'') || ' ' || coalesce(subtitle, '') || ' ' || coalesce(abstract, '') || ' ' || coalesce(description, '')",
               stored: true
  end
end
