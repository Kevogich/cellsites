class HeatAndMaterialBalance < ActiveRecord::Base
  
  belongs_to :project
  belongs_to :company
  
  has_many :raw_hm_sheets
  has_many :heat_and_material_properties
  has_many :streams, :through => :heat_and_material_properties
  
  has_attached_file :sheet, 
                    :url  => "/admin/:class/get_sheet/:id/:basename.:extension",
                    :path => "#{File.expand_path("..",Rails.root)}/shared/:class/:id/:basename.:extension",
                    :default_url => "/projects/sheets/original/no-excel.xls"

  
  #validates_attachment_presence :sheet
  validates_attachment_size :sheet, :less_than => 2.megabytes
  validates_attachment_content_type :sheet, :content_type => ['application/vnd.ms-excel']
  
  def self.excel_formates
    {1 => 'Hysys', 2 => 'ChemCad', 3 => 'Design II', 4 => 'Others', 5 => 'Aspen', 6 => 'Pro II', 7 => 'Unisim'}
  end
end
