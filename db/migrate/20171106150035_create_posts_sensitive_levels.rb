class CreatePostsSensitiveLevels < ActiveRecord::Migration
  def change
    create_table :posts_sensitive_levels do |t|
      t.integer :user_id
      t.string :post_type
      t.decimal :sensitive_level, :default => 0.0,:precision => 5, :scale => 2

      t.timestamps
    end
  end
end
