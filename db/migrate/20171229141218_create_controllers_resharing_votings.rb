class CreateControllersResharingVotings < ActiveRecord::Migration
  def change
    create_table :controllers_resharing_votings do |t|
      t.integer :user_id
      t.integer :allowed_aspects_ids

      t.timestamps
    end
  end
end
