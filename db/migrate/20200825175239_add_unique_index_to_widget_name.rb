class AddUniqueIndexToWidgetName < ActiveRecord::Migration[5.2]
  def change
    add_index :widgets, :name, unique: true
  end
end
