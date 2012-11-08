require 'zip/zipfilesystem'
require 'roo'
require "google_spreadsheet"

class Admin::HeatAndMaterialBalancesController < AdminController
  
  def show
    @id = params[:id].to_i
    @hnm = HeatAndMaterialBalance.where(:id => params[:id]).first
    
    @sheet_path = @hnm.sheet.path||"#{Rails.root}/public/projects/sheets/original/no-excel.xls"
         
    @excel = Excel.new(@sheet_path)
    @excel.default_sheet = @excel.sheets.first   
        
    render :layout => false
  end
  
  def new
    @row_no = params[:row_no]
    @project_id = params[:project_id]    
    @id = params[:id].to_i
    @hnm = HeatAndMaterialBalance.where(:id => params[:id]).first    
    @hnm_new = HeatAndMaterialBalance.new
    render :layout => false
  end
  
  def create
    @row_no = params[:row_no].to_s    
    @id = params[:id].to_i
    @hnm = HeatAndMaterialBalance.where(:id => params[:id]).first
    @hnm.update_attributes(params[:heat_and_material_balance]) if !@hnm.nil?    
    @hnm = HeatAndMaterialBalance.create(params[:heat_and_material_balance]) if @hnm.nil?
    
    @hnm.raw_hm_sheets.destroy_all   
    
    # loading excel data
    if !@hnm.sheet_file_name.nil?
      @excel = Excel.new(@hnm.sheet.path)
      @excel.default_sheet = @excel.sheets.first
      @hnm.heat_and_material_properties.delete_all
      property_start_row, property_start_column = params[:property_start_row].to_i, params[:property_start_column].to_i
      unit_start_row, unit_start_column = params[:unit_start_row].to_i, params[:unit_start_column].to_i
      property_data_start_row, property_data_start_column = params[:property_data_start_row].to_i, params[:property_data_start_column].to_i
      
      start_row, last_row = property_data_start_row, @excel.last_row
      start_column, last_column = property_data_start_column, @excel.last_column
      
      start_row.upto(last_row) do |x|
        if !@excel.cell(x,1).nil?
          property_params = {:phase => @excel.cell(x, 1), :property => @excel.cell(x,property_start_column), :unit => @excel.cell(x,unit_start_column)}
          @propery = @hnm.heat_and_material_properties.create(property_params)
          
          stream = []
          start_column.upto(last_column) do |y|
            stream << Stream.new({:heat_and_material_property_id => @propery.id, :stream_no => @excel.cell(2, y), :stream_value => @excel.cell(x,y)})
          end        
          
          Stream.import stream
        end
      end
      
    end
    
=begin    
    0.upto(@excel.last_row) do |x|
      0.upto(@excel.last_column) do |y|
        if x == 0
        elsif y == 0
        else
          rows << RawHmSheet.new({:heat_and_material_balance_id => @hnm.id, :column_no => y, :row_no => x, :cell_data => @excel.cell(x,y)})               
        end
      end
    end

    RawHmSheet.import rows
=end   
	flash[:notice] = "Successfully updated the details."
	redirect_to :back
    
  end  
    
  def destroy    
    @hnm = HeatAndMaterialBalance.find(params[:id])
    respond_to do |format|
      format.js      
    end
  end
  
  def delete_case   
    @id = params[:id]
    @hnm = HeatAndMaterialBalance.find(params[:id])
    @hnm.destroy    
    respond_to do |format|
      format.js      
    end
  end
  
  def get_stream_nos
    heat_and_meterial_balance = HeatAndMaterialBalance.find(params[:process_basis_id])    
    streams = heat_and_meterial_balance.heat_and_material_properties.first.streams
    streams_json = []
    streams.each do |stream|
      streams_json << {:display_stream_no => stream.display_stream_no, :stream_no => stream.stream_no}
    end  
    render :json => streams_json
  end

  def get_sheet
    heat_and_material_balance = HeatAndMaterialBalance.find(params[:id])
    send_file heat_and_material_balance.sheet.path, :type => heat_and_material_balance.sheet_content_type, :disposition => 'inline'
  end
end
