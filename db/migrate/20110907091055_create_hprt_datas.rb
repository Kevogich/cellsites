class CreateHprtDatas < ActiveRecord::Migration
  def self.up
    create_table :hprt_datas do |t|
      
      t.integer :hydraulic_turbine_id
      t.float :capacity, :limit => 53
      t.float :system_loss, :limit => 53

      t.timestamps
    end
  end

  def self.down
    drop_table :hprt_datas
  end
end
