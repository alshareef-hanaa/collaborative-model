class AddTrustLevelToAspects < ActiveRecord::Migration
  def change
    add_column :aspects, :trust_level, :decimal , :default => 0.0,:precision => 5, :scale => 2
  end
end
