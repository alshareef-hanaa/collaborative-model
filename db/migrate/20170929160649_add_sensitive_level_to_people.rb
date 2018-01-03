class AddSensitiveLevelToPeople < ActiveRecord::Migration
  def change
    add_column :people, :sensitive_level, :decimal, :default => 0.0,:precision => 5, :scale => 2
  end
end

