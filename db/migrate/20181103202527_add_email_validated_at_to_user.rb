class AddEmailValidatedAtToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :email_validated_at, :datetime
  end
end
