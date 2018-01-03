class CreateAllowedAspects < ActiveRecord::Migration
  def change
    create_table :allowed_aspects do |t|
      t.integer :user_id
      t.string :relationship_type
      t.integer :allowed_aspectids

      t.timestamps
    end
  end
end
