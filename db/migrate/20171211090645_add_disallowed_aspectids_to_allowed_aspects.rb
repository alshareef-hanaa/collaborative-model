class AddDisallowedAspectidsToAllowedAspects < ActiveRecord::Migration
  def change
    add_column :allowed_aspects, :disallowed_aspectids, :integer
  end
end
