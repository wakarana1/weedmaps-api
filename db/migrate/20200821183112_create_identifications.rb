class CreateIdentifications < ActiveRecord::Migration[6.0]
  def change
    create_table :identifications do |t|
      t.integer :number
      t.string :state
      t.date :expiration_date
      t.string :image_url
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
