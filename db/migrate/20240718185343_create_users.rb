class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :role
      t.string :status
      t.boolean :finalized
      t.boolean :display
      t.string :email
      t.string :email_confirmation
      t.string :password_hash
      t.string :password
      t.string :password_confirmation
      t.uuid :token
      t.string :jwt_token
      t.string :email_verification_token
      t.datetime :email_verified_at
      t.uuid :password_reset_token
      t.datetime :password_reset_expires_at
      t.string :first_name
      t.string :last_name
      t.string :phone_number
      t.uuid :avatar_key
      t.string :avatar_extension
      t.datetime :terms_of_use
      t.datetime :privacy_guidelines
      t.integer :agency_id
      t.datetime :last_active
      t.datetime :recertification_expired_at
      t.boolean :active_session
      t.string :renewal_request

      t.timestamps
    end
  end
end
