class CreateStaticDatas < ActiveRecord::Migration
  def self.up
    create_table :static_datas do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :static_datas
  end
end
