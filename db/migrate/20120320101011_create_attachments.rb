class CreateAttachments < ActiveRecord::Migration
  def self.up
    create_table :attachments do |t|

      t.string :name, :limit => 50
      t.string :description
      t.references :attachable, :polymorphic => true
      t.references :user

      t.string   :attachment_file_name
      t.string   :attachment_content_type
      t.integer  :attachment_file_size
      t.datetime :attachment_updated_at

      t.timestamps
    end
  end

  def self.down
    drop_table :attachments
  end
end
