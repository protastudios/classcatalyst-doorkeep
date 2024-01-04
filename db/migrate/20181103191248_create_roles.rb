class CreateRoles < ActiveRecord::Migration[5.2]
  def change
    create_table :roles do |t|
      t.references :user, foreign_key: true
      t.integer :role_type_id
      t.references :roleable, polymorphic: true

      t.timestamps
    end
  end
end
