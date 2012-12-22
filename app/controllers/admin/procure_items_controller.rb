class Admin::ProcureItemsController < AdminController
  before_filter :default_form_values, :only => [:new, :create, :edit, :update, :index]

  def index
    @procure_items = @company.procure_items.where(:item_type_id => params[:item_type_id], :process_unit_id => (user_project_setting.process_unit_id rescue 0))
    @item_type = ItemType.find params[:item_type_id]
    # raise user_project_setting.process_unit_id.inspect
  end

  def new
    @item_type = ItemType.find params[:item_type_id]
    @proposals = @company.procure_items.new
    @sizing_data = LineSizing.where(:process_unit_id => user_project_setting.process_unit_id)
    @sizing_data = LineSizing.where(:process_unit_id => user_project_setting.process_unit_id) if params[:sizing_value] == "line"
    @sizing_data = VesselSizing.where(:process_unit_id => user_project_setting.process_unit_id) if params[:sizing_value] == "vessel"
    @sizing_data = PumpSizing.where(:process_unit_id => user_project_setting.process_unit_id) if params[:sizing_value] == "pump"
    render :layout => false
  end

  def create

    unless params[:procure_item][:selection_type] == "new_item" and params["item_tags"].blank?

      params["item_tags"].each do |item_tag|
        transmit_proposals = params["procure_item"]
        @proposals = @company.procure_items.create(transmit_proposals)
        @proposals.item_type_id = params[:item_type_id]
        @proposals.item_tag = item_tag
        @proposals.created_by = current_user.id
        if @proposals.save
          @proposals.sizing_status_activities.create({:user_id => current_user.id, :status => 'new', :request_user_id => current_user.id})
        end
      end
      redirect_to admin_procure_items_path(:item_type_id => params[:item_type_id])
      flash[:notice] = "item tag(s) is/are added successfully"
    else
      transmit_proposals = params["procure_item"]
      @proposals = @company.procure_items.create(transmit_proposals)
      @proposals.item_type_id = params[:item_type_id]
      @proposals.item_tag = params["new_item"]
      @proposals.created_by = current_user.id
      if @proposals.save
        @proposals.sizing_status_activities.create({:user_id => current_user.id, :status => 'new', :request_user_id => current_user.id})
      end
      redirect_to admin_procure_items_path(:item_type_id => params[:item_type_id])
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


  def update
    # raise params.inspect
    proposals = params[:procure_item]
    #raise proposals.inspect
    @proposals = @company.procure_items.find(params[:id])
    item_type_id =  @proposals.item_type_id
    if @proposals.update_attributes(proposals)
      flash[:notice] = "Updated item type tag data successfully."
      redirect_to admin_procure_items_path(:item_type_id => item_type_id)
    end
  end

  def destroy
    @procure_item = ProcureItem.find(params[:id]).destroy
    @procure_item.destroy
    redirect_to admin_procure_items_path(:item_type_id => params[:item_type_id])
    flash[:notice] = "Procure Item deleted successfully"
  end


  def edit
    @procure_item = ProcureItem.find(params[:id])
  end

  def procure_item_purchase_items
    @purchase_item = ProcureItemPurchaseItem.new
    @unique_id = Time.now.to_i
    render :partial => 'purchase_items'
  end



  def default_form_values

    @procure = Procure.find(params[:id]) rescue Procure.new

    @comments = @procure.comments
    @new_comment = @procure.comments.new

    @attachments = @procure.attachments
    @new_attachment = @procure.attachments.new

  end

end
