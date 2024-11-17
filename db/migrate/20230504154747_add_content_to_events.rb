class AddContentToEvents < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :speaker_names, :string

    add_column :events,
               :content,
               :virtual,
               type: :string,
               as: "lower(coalesce(title,'') || ' ' || coalesce(subtitle, '') || ' ' || coalesce(abstract, '') || ' ' || coalesce(description, '') || ' ' || coalesce(speaker_names, ''))",
               stored: true
  end
end
