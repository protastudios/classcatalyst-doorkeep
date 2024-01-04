class CreateWidgets < ActiveRecord::Migration[5.2]
  def change
    create_table :widgets do |t|
      t.string :uid
      t.references :user, foreign_key: true
      t.string :name
      t.numeric :multiplier
      t.string :aasm_state

      t.timestamps
    end
  end
end
