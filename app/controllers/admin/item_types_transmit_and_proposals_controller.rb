class Admin::ItemTypesTransmitAndProposalsController < AdminController

  def index
    @proposals = @company.item_types_transmit_and_proposals.where(:item_type_id => params[:item_type_id], :process_unit_id => (user_project_setting.process_unit_id rescue 0))
    @item_type = ItemType.find params[:item_type_id]
    # raise user_project_setting.process_unit_id.inspect
  end

  def new
    @item_type = ItemType.find params[:item_type_id]
    @proposals = @company.item_types_transmit_and_proposals.new
    @sizing_data = LineSizing.where(:process_unit_id => user_project_setting.process_unit_id)
    @sizing_data = LineSizing.where(:process_unit_id => user_project_setting.process_unit_id) if params[:sizing_value] == "line"
    @sizing_data = VesselSizing.where(:process_unit_id => user_project_setting.process_unit_id) if params[:sizing_value] == "vessel"
    @sizing_data = PumpSizing.where(:process_unit_id => user_project_setting.process_unit_id) if params[:sizing_value] == "pump"
    render :layout => false
  end

  def create

    unless params[:item_types_transmit_and_proposal][:selection_type] == "new_item" and params["item_tags"].blank?

      params["item_tags"].each do |item_tag|
        transmit_proposals = params["item_types_transmit_and_proposal"]
        @proposals = @company.item_types_transmit_and_proposals.create(transmit_proposals)
        @proposals.item_type_id = params[:item_type_id]
        @proposals.item_tag = item_tag
        @proposals.save
      end
      redirect_to admin_item_types_transmit_and_proposals_path(:item_type_id => params[:item_type_id])
      flash[:notice] = "item tag(s) is/are added successfully"
    else
      transmit_proposals = params["item_types_transmit_and_proposal"]
      @proposals = @company.item_types_transmit_and_proposals.create(transmit_proposals)
      @proposals.item_type_id = params[:item_type_id]
      @proposals.item_tag = params["new_item"]
      @proposals.save
      redirect_to admin_item_types_transmit_and_proposals_path(:item_type_id => params[:item_type_id])
      flash[:notice] = "new item tag is created successfully"
    end
  end


  def sizing_data
    #raise params[:sizing_value].inspect
    @sizing_data = LineSizing.where(:process_unit_id => user_project_setting.process_unit_id)
    @sizing_data = LineSizing.where(:process_unit_id => user_project_setting.process_unit_id) if params[:sizing_value] == "line"
    @sizing_data = VesselSizing.where(:process_unit_id => user_project_setting.process_unit_id) if params[:sizing_value] == "vessel"
    @sizing_data = PumpSizing.where(:process_unit_id => user_project_setting.process_unit_id) if params[:sizing_value] == "pump"

    @sizing_data = CompressorSizing.where(:process_unit_id => user_project_setting.process_unit_id) if params[:sizing_value] == "compressor"
    @sizing_data = VesselSizing.where(:process_unit_id => user_project_setting.process_unit_id) if params[:sizing_value] == "driver"
    @sizing_data = ControlValveSizing.where(:process_unit_id => user_project_setting.process_unit_id) if params[:sizing_value] == "control_value"

    @sizing_data = FlowElementSizing.where(:process_unit_id => user_project_setting.process_unit_id) if params[:sizing_value] == "flow_element"
    @sizing_data = StorageTankSizing.where(:process_unit_id => user_project_setting.process_unit_id) if params[:sizing_value] == "storage_tank"
    @sizing_data = ColumnSizing.where(:process_unit_id => user_project_setting.process_unit_id) if params[:sizing_value] == "column"

    @sizing_data = HeatExchangerSizing.where(:process_unit_id => user_project_setting.process_unit_id) if params[:sizing_value] == "heat_exchanger"
    @sizing_data = ReliefDeviceSizing.where(:process_unit_id => user_project_setting.process_unit_id) if params[:sizing_value] == "relief_device"

  end

  def edit
    @proposals = @company.item_types_transmit_and_proposals.find params[:id]
    @datasheets = Datasheet.where(:company_id => current_user.id,:item_type_id => params[:item_type_id] )
    @item_type = ItemType.find params[:item_type_id]
    @comment = @proposals.comments.new
    @attachment = @proposals.attachments.new
    @comments_tab1 = @proposals.comments.where(:item_tag_tab => "applicable_specification")
    @attachments_tab1 = @proposals.attachments.where(:item_tag_tab => "applicable_specification")
    @comments_tab2 = @proposals.comments.where(:item_tag_tab => "Supplemental_design")
    @attachments_tab2 = @proposals.attachments.where(:item_tag_tab => "Supplemental_design")
    @comments_tab4 = @proposals.comments.where(:item_tag_tab => "datasheet")
    @attachments_tab4 = @proposals.attachments.where(:item_tag_tab => "datasheet")
   # raise VendorScheduleSetup.all.inspect
    @vendor_setups = ItemTagVendorScheduleSetup.where(:project_id => user_project_setting.project_id, :item_type_id =>  params[:item_type_id])
     #raise @vendor_setups.inspect
  end

  def update
   # raise params.inspect
    proposals = params[:item_types_transmit_and_proposal]
    #raise proposals.inspect
    @proposals = @company.item_types_transmit_and_proposals.find(params[:id])
    if @proposals.update_attributes(proposals)
      flash[:notice] = "Updated item type tag data successfully."
      redirect_to admin_item_types_transmit_and_proposals_path(:item_type_id => params[:item_type_id])
    end
  end
  def engineering_data_form
   # raise params.inspect
   matched_electronic_data = ElectronicData.where("item_tag_id"=>params[:item_tag_id], "item_type_id"=>params[:item_type_id], "datasheet_id"=>params[:datasheet_id])
   matched_electronic_data.blank??  @electronic_data = ElectronicData.new : @electronic_data = matched_electronic_data[0]

    render :layout => false
  end
  def electronic_data_new
    #raise "check"
    @electronic_data = ElectronicData.new(params[:electronic_data])
    if @electronic_data.save
    redirect_to :back
      end
  end
  def electronic_data_update

    matched_electronic_data = ElectronicData.where("item_tag_id"=>params[:electronic_data][:item_tag_id], "item_type_id"=>params[:electronic_data][:item_type_id], "datasheet_id"=>params[:electronic_data][:datasheet_id])
    @electronic_data = ElectronicData.find matched_electronic_data[0].id
    electronic_data = params[:electronic_data]
    if @electronic_data.update_attributes(matched_electronic_data)
      redirect_to :back
    end

  end
  def bid_evaluation
    @bid_evaluation = @company.item_types_transmit_and_proposals.find params[:id]

  end


end
