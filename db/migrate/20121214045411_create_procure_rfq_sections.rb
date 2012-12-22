class CreateProcureRfqSections < ActiveRecord::Migration
  def self.up
    create_table :procure_rfq_sections do |t|
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :procure_rfq_sections
  end
end
