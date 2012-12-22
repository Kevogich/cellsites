class CreateProcureAdditionalPoCosts < ActiveRecord::Migration
  def self.up
    create_table :procure_additional_po_costs do |t|
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :procure_additional_po_costs
  end
end
