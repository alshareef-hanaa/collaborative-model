class CreateAspectsLevelsOfSenstivityAndTrusts < ActiveRecord::Migration
  def change
    create_table :aspects_levels_of_senstivity_and_trusts do |t|
      t.integer :user_id
      t.string :relationship_type
      t.decimal :sensitive_level, :default => 0.0,:precision => 5, :scale => 2
      t.decimal :trust_level, :default => 0.0,:precision => 5, :scale => 2

      t.timestamps
    end
  end
end
