class AddContentVectorToEvents < ActiveRecord::Migration[7.0]
  def change
    add_column :events,
               :content_searchable,
               type: :tsvector,
               as: "to_tsvector('english', coalesce(title,'') || ' ' || coalesce(subtitle, '') || ' ' || coalesce(abstract, '') || ' ' || coalesce(description, ''))",
               stored: true

    add_index :events, :content_searchable, using: :gin, name: 'events_content_searchable_idx'
  end
end
