class CreateTranslations < ActiveRecord::Migration[5.2]
  def change
    create_table :translations do |t|
      t.string :locale
      t.string :key
      t.text :value
      t.text :interpolations
      t.boolean :is_proc

      t.timestamps
    end
    add_index 'translations', %w[locale key], unique: true
  end
end
