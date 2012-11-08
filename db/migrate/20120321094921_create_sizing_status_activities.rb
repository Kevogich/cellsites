class CreateSizingStatusActivities < ActiveRecord::Migration
  def self.up
    create_table :sizing_status_activities do |t|
      t.references :user
      t.references :sizing, :polymorphic => true
      t.string :status
      t.integer :request_user_id

      t.timestamps
    end

    puts '########## Clear status activities ##########'
    SizingStatusActivity.destroy_all

    StaticData.sizings.each do |sizings|
      sizings.classify.constantize.all.each do |s|
        s.sizing_status_activities.create({:user_id => 2, :request_user_id => 2, :status => 'new'})
      end
    end
  end

  def self.down
    drop_table :sizing_status_activities
  end
end
