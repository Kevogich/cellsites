class CreateMinimumRefluxRatios < ActiveRecord::Migration
  def self.up
    create_table :minimum_reflux_ratios do |t|
      t.integer :column_sizing_id

      t.boolean :lk
      t.boolean :hk
      t.boolean :basis

      t.string :component
      t.float :feed_mole
      t.float :distillate_mole
      t.float :k_value_feed

      t.float :relative_volatility

      t.timestamps
    end
  end

  def self.down
    drop_table :minimum_reflux_ratios
  end
end
