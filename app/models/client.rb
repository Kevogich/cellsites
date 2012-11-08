class Client < ActiveRecord::Base
  belongs_to :company
  has_many :projects
  
  has_attached_file :logo,                    
                    :url  => "/clients/logo/:id/:basename.:extension",
                    :path => ":rails_root/public/clients/logo/:id/:basename.:extension",
                    :default_url => "/clients/original/no-client-logo.png"
                    
  validates_attachment_content_type :logo, :content_type => ['image/jpeg', 'image/png']                    

  validates_presence_of :name, :client_type, :email
end
