class AddEmailValidationTokenToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :email_validation_token, :string
  end
end
