class AddUniqueIndexToGlobalSettingsName < ActiveRecord::Migration[5.2]
  def change
    add_index :global_settings, :name, unique: true
  end
end
