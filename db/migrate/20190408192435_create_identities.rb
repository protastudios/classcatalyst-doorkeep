class CreateIdentities < ActiveRecord::Migration[5.2]
  def change
    create_table :identities do |t|
      t.references :user, foreign_key: true
      t.string :provider
      t.string :uid
      t.string :token
      t.jsonb :info
      t.jsonb :extra

      t.index %i[provider uid], unique: true
      t.timestamps
    end
  end
end
