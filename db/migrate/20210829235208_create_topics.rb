class CreateTopics < ActiveRecord::Migration[5.1]
  def change
    create_table :topics do |t|
      t.integer :member_id
      t.text :title

      t.timestamps
    end
  end
end
