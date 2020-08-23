class AddUuidToUsers < ActiveRecord::Migration[6.0]
  def up
    add_column :users,                    :uuid, :uuid, null: false, default: -> { "gen_random_uuid()" }
    add_column :medical_recommendations,  :uuid, :uuid, null: false, default: -> { "gen_random_uuid()" }
    add_column :identifications,          :uuid, :uuid, null: false, default: -> { "gen_random_uuid()" }

    add_column :medical_recommendations,  :user_uuid, :uuid
    add_column :identifications,          :user_uuid, :uuid

    execute <<-SQL
      UPDATE medical_recommendations SET user_uuid = users.uuid
      FROM users WHERE medical_recommendations.user_id = users.id;
      UPDATE identifications SET user_uuid = users.uuid
      FROM users WHERE identifications.user_id = users.id;
    SQL

    change_column_null :medical_recommendations,  :user_uuid, false
    change_column_null :identifications,          :user_uuid, false

    remove_column :medical_recommendations, :user_id
    rename_column :medical_recommendations, :user_uuid, :user_id
    remove_column :identifications,         :user_id
    rename_column :identifications,         :user_uuid, :user_id

    add_index :medical_recommendations, :user_id
    add_index :identifications,         :user_id

    remove_column :users,                   :id
    remove_column :medical_recommendations, :id
    remove_column :identifications,         :id
    rename_column :users,                   :uuid, :id
    rename_column :medical_recommendations, :uuid, :id
    rename_column :identifications,         :uuid, :id
    execute "ALTER TABLE users    ADD PRIMARY KEY (id);"
    execute "ALTER TABLE medical_recommendations ADD PRIMARY KEY (id);"
    execute "ALTER TABLE identifications ADD PRIMARY KEY (id);"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
