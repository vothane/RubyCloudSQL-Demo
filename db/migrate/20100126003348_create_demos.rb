class CreateDemos < ActiveRecord::Migration
  def self.up
    create_table :demos do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :demos
  end
end
