class CreateDisallowedAspects < ActiveRecord::Migration
  def change
    create_table :disallowed_aspects do |t|
      t.integer :user_id
      t.string :relationship_type
      t.integer :disallowed_aspectids

      t.timestamps
    end
  end
end
