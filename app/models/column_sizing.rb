class ColumnSizing < ActiveRecord::Base
  belongs_to :company
  belongs_to :client
  belongs_to :project
  belongs_to :process_unit
  has_many :minimum_reflux_ratios, :dependent => :destroy
  has_many :column_tray_specifications, :dependent => :destroy
  has_many :attachments, :as => :attachable, :dependent => :destroy
  has_many :sizing_status_activities, :as => :sizing, :dependent => :destroy

  acts_as_commentable

  validates_presence_of :column_system, :project_id, :process_unit_id

  accepts_nested_attributes_for :column_tray_specifications

  after_save :save_minimum_reflux_ratios#, :save_column_section_tray_designs

  def minimum_reflux_ratios=(mrr_params)
     @mrr_params = mrr_params
  end

  def save_minimum_reflux_ratios
    #raise @mrr_params.to_yaml
    @mrr_params.each do |i, mrr_param|
      mrr_param[:lk] = 0 if !mrr_param.has_key?(:lk)
      mrr_param[:hk] = 0 if !mrr_param.has_key?(:hk)
      mrr_param[:basis] = 0 if !mrr_param.has_key?(:basis)
      mrr = minimum_reflux_ratios.where(:id => mrr_param[:id]).first
      minimum_reflux_ratios.create(mrr_param) if mrr.nil? && !mrr_param[:component].blank? #create
      mrr.delete if !mrr.nil? && mrr_param[:component].blank? #delete
      mrr.update_attributes(mrr_param) if !mrr.nil? && !mrr_param[:component].blank? #update
    end if !@mrr_params.nil?
  end

=begin
  def column_section_tray_designs=(cstd_params)
    @cstd_params = cstd_params
  end

  def save_column_section_tray_designs
    #raise @cstd_params.to_yaml
    @cstd_params.each do |i, cstd_param|
      cstd = column_section_tray_designs.where(:id => cstd_param[:id]).first
      column_section_tray_designs.create(cstd_param) if cstd.nil? && !cstd_param[:zd_section_description].blank? #create
      cstd.delete if !cstd.nil? && cstd_param[:zd_section_description].blank? #delete
      cstd.update_attributes(cstd_param) if !cstd.nil? && !cstd_param[:zd_section_description].blank? #update
    end if !@cstd_params.nil?
  end
=end

  #convert values
  def convert_values(multiply_factor,project)

  end

end
