class AddTrThresholdToPeople < ActiveRecord::Migration
  def change
    add_column :people, :tr_threshold, :decimal, :default => 0.0,:precision => 5, :scale => 2
  end
end
