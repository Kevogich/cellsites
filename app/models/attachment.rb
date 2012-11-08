class Attachment < ActiveRecord::Base
  belongs_to :user
  belongs_to :attachable, :polymorphic => true

  Paperclip.interpolates :attached_to do |attachment, style|
    attachment.instance.attachable.class.to_s.downcase
  end

  has_attached_file :attachment,
                    :url  => "/attachments/:id/:basename.:extension",
                    #:path => "#{ATTACHMENTS_FOLDER}/attachments/:id/:basename.:extension",
                    :path => "#{File.expand_path("..",Rails.root)}/shared/attachments/:attached_to/:id/:basename.:extension",
                    :default_url => "/attachments/original/no-file.txt"

  validates_attachment_presence :attachment

  default_scope :order => 'created_at DESC'
  scope :recent, order('created_at DESC').limit(5)

end
