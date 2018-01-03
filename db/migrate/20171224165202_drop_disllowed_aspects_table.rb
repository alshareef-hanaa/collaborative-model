class DropDisllowedAspectsTable < ActiveRecord::Migration
  def up
    drop_table :disllowed_aspects
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
