class CreateGlobalSettings < ActiveRecord::Migration[5.2]
  def change
    create_table :global_settings do |t|
      t.string :name
      t.jsonb :value

      t.timestamps
    end
  end
end
