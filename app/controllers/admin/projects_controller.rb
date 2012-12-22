class Admin::ProjectsController < AdminController

  respond_to :html, :json

  before_filter :find_project, :only => [:show, :edit, :update, :destroy]

  def index
    @projects = @company.projects
  end

  def show
    @comments = @project.comments
    @new_comment = @project.comments.new
    @attachments = @project.attachments
    @new_attachment = @project.attachments.new
    @pipe_r_cf = pipe_roughness_cf(@project)
    @item_types = @project.item_types
    # raise @item_types.inspect
  end

  def destroy
    @project.destroy
    flash[:notice] = "Project has been deleted"
    respond_to do |format|
      format.js
      format.html { redirect_to admin_projects_path }
    end
  end

  def new
    @project = Project.new
  end

  def create
    @project = @company.projects.new(params[:project])
    @project.units_of_measurement_id = 2
    if @project.save
      flash[:notice] = "Project has been created"
      redirect_to edit_steps_admin_project_path(@project, :step => @project.next_step[:id])
    else
      flash[:notice] = "Project can not be saved"
      render :new
    end
  end

  def edit
    @project.current_step = params[:step].to_sym if params[:step].present?

    if params[:step] == "measurement_unit" # unit of measurements
      if @project.unit_of_measurements.length == 0 #putting SI units
        @project.units_of_measurement_id = 2
        measure_units = @company.measure_units.group(:measurement_id, :measurement_sub_type_id).order("id ASC")
        measure_units.each do |measure_unit|
          @project.unit_of_measurements.create({
                                                 :company_id => @company.id,
                                                 :measurement_id => measure_unit.measurement_id,
                                                 :measurement_sub_type_id => measure_unit.measurement_sub_type_id,
                                                 :measure_unit_id => measure_unit.id,
                                                 :measure_type => "SI",
                                                 :created_by => current_user.id,
                                                 :updated_by => current_user.id
                                               })
        end
        @project.save
      end
    elsif params[:step] == "process_units" #process_units

    elsif params[:step] == "pipe_roughness" #pipe roughness
      @pipe_r_cf = pipe_roughness_cf(@project)
    elsif params[:step] == "sizing_criteria" #sizing criteria
      project_sizing_criterias = @project.project_sizing_criterias
      project_sizing_criteria_ids = [0]
      project_sizing_criterias.each do |project_sizing_criteria|
        project_sizing_criteria_ids << project_sizing_criteria.sizing_criteria_id
      end

      sizing_criterias = @company.sizing_criterias.where("sizing_criterias.id NOT IN (?)", project_sizing_criteria_ids)
      #need unit conversion when creating sizing criterias
      #for velocity from ft/s to current project value
      #for pressure from psi to current project value
      cf = sizing_criteria_cf(@project)

      sizing_criterias.each do |sizing_criteria|
        psc = {
          :sizing_criteria_category_id => sizing_criteria.sizing_criteria_category_id,
          :sizing_criteria_category_type_id => sizing_criteria.sizing_criteria_category_type_id,
          :sizing_criteria_id => sizing_criteria.id,
          :velocity_min => (sizing_criteria.velocity_min * cf[:vcf]).round(cf[:vdp]),
          :velocity_max => (sizing_criteria.velocity_max * cf[:vcf]).round(cf[:vdp]),
          :velocity_sel => (sizing_criteria.velocity_sel * cf[:vcf]).round(cf[:vdp]),
          :delta_per_100ft_min => (sizing_criteria.delta_per_100ft_min * cf[:dcf]).round(cf[:ddp]),
          :delta_per_100ft_max => (sizing_criteria.delta_per_100ft_max * cf[:dcf]).round(cf[:ddp]),
          :delta_per_100ft_sel => (sizing_criteria.delta_per_100ft_sel * cf[:dcf]).round(cf[:ddp]),
          :user_notes => sizing_criteria.user_notes,
          :created_by => sizing_criteria.created_by,
          :updated_by => sizing_criteria.updated_by
        }
        @project.project_sizing_criterias.create(psc)
      end
    elsif params[:step] == "pressure_relief_system_design_parameter" #spressure relief system design parameter
      pressure_relief_system_design_parameter = @project.pressure_relief_system_design_parameter
      if pressure_relief_system_design_parameter.nil?
        @project.build_pressure_relief_system_design_parameter
        @project.save
      end

      @pipe_size_cf = @project.specified_units_cf({:mtype => "Length", :msub_type => "Small Dimension Length", :previous_unit => "Inches"})
    elsif params[:step] == "vendor_schedule_setup"
      VendorScheduleSetup.delete(params[:vendor_setup_id]) unless params[:vendor_setup_id].nil?
      @item_types = ItemType.all
      @vendors = VendorDataRequirement.all
      # raise @item_types.inspect
      unless @item_types.blank?
        required_schedule_data = VendorScheduleSetup.find(params[:setup_id]) unless params[:setup_id].nil?
        unless params[:vendor_required_data].nil? and params[:setup_id].nil?
          required_schedule_data.vendor_required_data = params[:vendor_required_data]
          required_schedule_data.save
          required_item_tag_schedule_setup_data = ItemTagVendorScheduleSetup.where(:vendor_schedule_setup_id => params[:setup_id])
          required_item_tag_schedule_setup_data[0].vendor_required_data = params[:vendor_required_data]
          required_item_tag_schedule_setup_data[0].save
        end
        params[:item_id].nil? ? @item_type = @item_types[0] : @item_type = ItemType.find(params[:item_id])
        @vendor_setup = VendorScheduleSetup.where(:project_id => params[:id], :item_type_id => @item_type.id)
        project_item_type = ProjectItemType.where(:project_id => params[:id], :item_type_id => params[:item_id]) unless params[:item_id].nil?
        @vendor_setups = VendorScheduleSetup.where(:project_id => params[:id])
        #raise project_item_type.inspect
        ProjectItemType.create(:project_id => params[:id], :item_type_id => params[:item_id]) if project_item_type.blank?
        if @vendor_setup.empty?
          @vendor_schedule_setup = @item_type.vendor_schedule_setups.create
          @vendor_schedule_setup.project_id = params[:id]
          @vendor_schedule_setup.vendor_required_data = @vendors[0].id
          @vendor_schedule_setup.save
          ItemTagVendorScheduleSetup.create(:vendor_schedule_setup_id => @vendor_schedule_setup.id, :project_id => @vendor_schedule_setup.project_id, :vendor_required_data => @vendor_schedule_setup.vendor_required_data, :item_type_id => @vendor_schedule_setup.item_type_id)
        end
      else
        redirect_to admin_mechanical_specifications_path
        flash[:error] ="Please Create atleast one Item Type"
      end
    elsif params[:step] == "request_for_quotation_setup" #request for quotation setup
      request_for_quotation_setups = @project.request_for_quotation_setups.order("item_type_id,procure_rfq_section_id")
      @procure_rfq_sections = ProcureRfqSection.all
      @item_types = ItemType.where(:company_id => current_user.id )
      rfq_ids = [0]
      item_ids = [0]
      request_for_quotation_setups.each do |request_for_quotation_setup|
        rfq_ids << request_for_quotation_setup.procure_rfq_section_id
        item_ids << request_for_quotation_setup.item_type_id
      end

      # search for a new entries in procure_rfq_sections
      procure_rfq_sections = ProcureRfqSection.where("id NOT IN (?)", rfq_ids)
      # add new procure_rfq_sections in request_for_quotation_setups
      unless procure_rfq_sections.empty?
        item_types = @item_types.where("id IN (?)", item_ids)
          #dont use @procure_rfq_sections create records for only new procure_rfq_sections
          procure_rfq_sections.each do |procure_rfq_section|
            item_types.each do |item_type|
            rfq = {
              :procure_rfq_section_id => procure_rfq_section.id,
              :item_type_id => item_type.id,
              :status => 0
            }
            @project.request_for_quotation_setups.create(rfq)
            end
          end
      end

      # search for a new entries in item_types
      item_types = @item_types.where("id NOT IN (?)", item_ids)
      # add new procure_rfq_sections in request_for_quotation_setups
      unless item_types.empty?
        item_types.each do |item_type|
          @procure_rfq_sections.each do |procure_rfq_section|
            rfq = {
              :procure_rfq_section_id => procure_rfq_section.id,
              :item_type_id => item_type.id,
              :status => 0
            }
            @project.request_for_quotation_setups.create(rfq)
          end
        end
      end
      @request_for_quotation_setups = @project.request_for_quotation_setups.order("item_type_id,procure_rfq_section_id")
    end
  end

  def update
    if params[:project][:current_step] == "process_units" #process_units
      params[:project][:process_units].each do |i, process_unit|
        process_unit[:created_by] = current_user.id
        process_unit[:updated_by] = current_user.id
      end
    end

    if @project.update_attributes(params[:project])
      if params[:commit] == "Save"
        redirect_to admin_project_path
      else
        if next_step = @project.next_step
          redirect_to edit_steps_admin_project_path(@project, :step => next_step[:id])
        else
          flash[:notice] = "Project has been updated"
          redirect_to admin_project_path(@project)
        end
      end
    else
      flash[:error] = "Project can not be saved"
      render :edit
    end
  end

  def assign
    @company_users = @company.company_users
    @project = Project.find params[:id]
    @project_users = @project.users.collect { |u| u.id }
  end

  def assign_vendors
    @company_vendors = @company.vendor_lists
    @project = Project.find params[:id]
    @project_vendors = @project.vendor_lists.collect { |v| v.id }
    #raise @project_vendors.inspect
  end


  def team_assignment
    @project = Project.find params[:id]
    if params[:users]
      @project.users = []
      params[:users].each do |u|
        @project.users << User.find(u)
      end
    end
    flash[:notice] = "Project assigned successfully!"
    redirect_to :action => "assign"
  end

  def vendor_assignment
    @project = Project.find params[:id]
    if params[:vendors]

      @project.vendor_lists = []
      params[:vendors].each do |v|
        @project.vendor_lists << VendorList.find(v)
      end
    end
    #raise @project.vendor_lists.inspect
    flash[:notice] = "Vendors assigned successfully!"
    redirect_to :action => "assign_vendors"
  end

  def find_project
    @project = Project.find params[:id]
    @breadcrumbs << {:name => @project.project_num, :url => admin_project_path}
    unless @project
      # raise error!
    end
  end

  def project_case_details

    render :layout => false
  end

  def update_case_details

    respond_to do |format|
      format.js
    end
  end

  def project_details
    @project = Project.find(params[:project_id])

    respond_to do |format|
      format.json { render :json => {:project => @project} }
    end
  end

  def set_breadcrumbs
    super
    @breadcrumbs << {:name => 'Projects', :url => admin_projects_path}
  end

  #convert and truncate
  #given a measure unit and subtype of unit
  #according to project settings
  def convert_and_round
    value = params[:value].to_f
    @project = Project.find(params[:id])
    cf = {}
    if params.key?(:previous_unit)
      cf = @project.specified_units_cf(:mtype => params[:mtype], :msub_type => params[:subtype], :previous_unit => params[:previous_unit])
    else
      cf = @project.unit_conversion_factor(:mtype => params[:mtype], :msub_type => params[:subtype])
    end
    render :json => {:converted_value => (value * cf[:factor]).round(cf[:decimals]), :decimals => cf[:decimals], :cfactor => cf[:factor]}
  end


  def vendor_setups
    #raise params[:item_type_id].inspect
    @project = Project.find params[:project_id]
    @vendors = VendorDataRequirement.all
    @item_type = ItemType.find params[:item_type_id]
    @vendor_schedule_setup = @item_type.vendor_schedule_setups.create
    @vendor_schedule_setup.project_id = params[:project_id]
    @vendor_schedule_setup.vendor_required_data = @vendors[0].id
    @vendor_schedule_setup.save
    ItemTagVendorScheduleSetup.create(:vendor_schedule_setup_id => @vendor_schedule_setup.id, :project_id => @vendor_schedule_setup.project_id, :vendor_required_data => @vendor_schedule_setup.vendor_required_data, :item_type_id => @vendor_schedule_setup.item_type_id)
    @unique_id = Time.now.to_i
    render :partial => 'vendor_setups'
  end

  def edit_vendor_schedule_setup
    #raise params.inspect
    @vendor_schedule_setup = VendorScheduleSetup.find params[:id] unless params[:id].nil?
    @vendor_schedule_setup_item_tag = VendorScheduleSetup.find params[:setup_id] unless params[:setup_id].nil?
    unless params[:item_tag_id].nil?
      @item_tag_vendor_schedule_setup = ItemTagVendorScheduleSetup.find params[:item_tag_id]
      @item_tag_vendor_schedule_setup.quotation = @item_tag_vendor_schedule_setup.quotation.nil? ? @vendor_schedule_setup_item_tag.quotation : @item_tag_vendor_schedule_setup.quotation
      @item_tag_vendor_schedule_setup.save
      #raise @item_tag_vendor_schedule_setup.inspect
    end
    unless params[:setup_id].nil?
      @vendor_schedule_setup1 = ItemTagVendorScheduleSetup.where(:vendor_schedule_setup_id => params[:setup_id])
      @vendor_schedule_setup = @vendor_schedule_setup1[0]
    end
    @vendor_required_data = VendorDataRequirement.find params[:required_data]
    if params[:page]== "item_tag"
      @proposals = @company.item_types_transmit_and_proposals.find params[:item_proposal_id]
      @attachments_tab3 = @proposals.attachments.where(:item_tag_tab => "#{params[:item_proposal_id]}_#{params[:item_tag_id]}_quotation")
      @attachment = @proposals.attachments.new
      @comments_tab4 = @proposals.comments.where(:item_tag_tab => "#{params[:item_proposal_id]}_#{params[:item_tag_id]}_quotation")
      @comment = @proposals.comments.new
    end
    render :layout => false
  end

  def edit_purchase_vendor_schedule_setup
    @vendor_schedule_setup = VendorScheduleSetup.find params[:id] unless params[:id].nil?
    @vendor_schedule_setup_item_tag = VendorScheduleSetup.find params[:setup_id] unless params[:setup_id].nil?

    unless params[:item_tag_id].nil?
      @item_tag_vendor_schedule_setup = ItemTagVendorScheduleSetup.find params[:item_tag_id]
      @item_tag_vendor_schedule_setup.purchase = @item_tag_vendor_schedule_setup.purchase.nil? ? @vendor_schedule_setup_item_tag.purchase : @item_tag_vendor_schedule_setup.purchase
      @item_tag_vendor_schedule_setup.save
      #raise @item_tag_vendor_schedule_setup.inspect
    end
    unless params[:setup_id].nil?
      @vendor_schedule_setup1 = ItemTagVendorScheduleSetup.where(:vendor_schedule_setup_id => params[:setup_id])
      @vendor_schedule_setup = @vendor_schedule_setup1[0]
    end
    @vendor_required_data = VendorDataRequirement.find params[:required_data]
    if params[:page]== "item_tag"
      @proposals = @company.item_types_transmit_and_proposals.find params[:item_proposal_id]
      @attachments_tab3 = @proposals.attachments.where(:item_tag_tab => "#{params[:item_proposal_id]}_#{params[:item_tag_id]}_purchase")
      @attachment = @proposals.attachments.new
      @comments_tab4 = @proposals.comments.where(:item_tag_tab => "#{params[:item_proposal_id]}_#{params[:item_tag_id]}_purchase")
      @comment = @proposals.comments.new
    end
    render :layout => false
  end

  def edit_as_built_vendor_schedule_setup
    @vendor_schedule_setup = VendorScheduleSetup.find params[:id] unless params[:id].nil?
    @vendor_schedule_setup_item_tag = VendorScheduleSetup.find params[:setup_id] unless params[:setup_id].nil?

    unless params[:item_tag_id].nil?
      @item_tag_vendor_schedule_setup = ItemTagVendorScheduleSetup.find params[:item_tag_id]
      @item_tag_vendor_schedule_setup.as_built = @item_tag_vendor_schedule_setup.as_built.nil? ? @vendor_schedule_setup_item_tag.as_built : @item_tag_vendor_schedule_setup.as_built
      @item_tag_vendor_schedule_setup.save
      #raise @item_tag_vendor_schedule_setup.quotation.inspect
    end
    unless params[:setup_id].nil?
      @vendor_schedule_setup1 = ItemTagVendorScheduleSetup.where(:vendor_schedule_setup_id => params[:setup_id])
      @vendor_schedule_setup = @vendor_schedule_setup1[0]
    end
    @vendor_required_data = VendorDataRequirement.find params[:required_data]
    if params[:page]== "item_tag"
      @proposals = @company.item_types_transmit_and_proposals.find params[:item_proposal_id]
      @attachments_tab3 = @proposals.attachments.where(:item_tag_tab => "#{params[:item_proposal_id]}_#{params[:item_tag_id]}_as_built")
      @attachment = @proposals.attachments.new
      @comments_tab4 = @proposals.comments.where(:item_tag_tab => "#{params[:item_proposal_id]}_#{params[:item_tag_id]}_as_built")
      @comment = @proposals.comments.new
    end
    render :layout => false
  end

  def edit_with_shipment_vendor_schedule_setup
    @vendor_schedule_setup = VendorScheduleSetup.find params[:id] unless params[:id].nil?
    @vendor_schedule_setup_item_tag = VendorScheduleSetup.find params[:setup_id] unless params[:setup_id].nil?

    unless params[:item_tag_id].nil?
      @item_tag_vendor_schedule_setup = ItemTagVendorScheduleSetup.find params[:item_tag_id]
      @item_tag_vendor_schedule_setup.with_shipment = @item_tag_vendor_schedule_setup.with_shipment.blank? ? @vendor_schedule_setup_item_tag.with_shipment : @item_tag_vendor_schedule_setup.with_shipment
      @item_tag_vendor_schedule_setup.save
      #raise @item_tag_vendor_schedule_setup.quotation.inspect
    end
    unless params[:setup_id].nil?
      @vendor_schedule_setup1 = ItemTagVendorScheduleSetup.where(:vendor_schedule_setup_id => params[:setup_id],)
      @vendor_schedule_setup = @vendor_schedule_setup1[0]
    end
    @vendor_required_data = VendorDataRequirement.find params[:required_data]
    if params[:page]== "item_tag"
      @proposals = @company.item_types_transmit_and_proposals.find params[:item_proposal_id]
      @attachments_tab3 = @proposals.attachments.where(:item_tag_tab => "#{params[:item_proposal_id]}_#{params[:item_tag_id]}_with_shipment")
      @attachment = @proposals.attachments.new
      @comments_tab4 = @proposals.comments.where(:item_tag_tab => "#{params[:item_proposal_id]}_#{params[:item_tag_id]}_with_shipment")
      @comment = @proposals.comments.new
    end
    render :layout => false
  end

  def edit_request_for_quotation_setup
    @rfq_setup = RequestForQuotationSetup.find params[:rfq_section_id]

    @comments = @rfq_setup.comments
    @new_comment = @rfq_setup.comments.new

    @attachments = @rfq_setup.attachments
    @new_attachment = @rfq_setup.attachments.new

    render :layout => false
  end

  def update_vendor_schedule_setup
    # raise params.inspect
    @vendor_schedule_setup = VendorScheduleSetup.find params[:vendor_schedule_setup][:id] if params[:page] == "project"
    @vendor_schedule_setup = ItemTagVendorScheduleSetup.find params[:item_tag_vendor_schedule_setup][:id] if params[:page] == "item_tag"
    @vendor_schedule_setup.update_attributes params[:vendor_schedule_setup] if params[:page] == "project"
    @vendor_schedule_setup.update_attributes params[:item_tag_vendor_schedule_setup] if params[:page] == "item_tag"
    if (params[:page] == "item_tag")
      @vendor_schedule_setup.quotation = params[:item_tag_vendor_schedule_setup][:quotation]
      @vendor_schedule_setup.save
    end
    (params[:page] == "project") ? (redirect_to edit_steps_admin_project_path(@vendor_schedule_setup.project_id, :step => "vendor_schedule_setup") if !request.xhr?) : (redirect_to edit_admin_item_types_transmit_and_proposal_path(proposal, :item_type_id => @vendor_schedule_setup.item_type_id) if !request.xhr?)
  end

  def update_purchase_vendor_schedule_setup
    @vendor_schedule_setup = VendorScheduleSetup.find params[:vendor_schedule_setup][:id] if params[:page] == "project"
    @vendor_schedule_setup = ItemTagVendorScheduleSetup.find params[:item_tag_vendor_schedule_setup][:id] if params[:page] == "item_tag"
    @vendor_schedule_setup.update_attributes params[:vendor_schedule_setup]
    if (params[:page] == "item_tag")
      @vendor_schedule_setup.purchase = params[:item_tag_vendor_schedule_setup][:purchase]
      @vendor_schedule_setup.save
    end
    (params[:page] == "project") ? (redirect_to edit_steps_admin_project_path(@vendor_schedule_setup.project_id, :step => "vendor_schedule_setup") if !request.xhr?) : (redirect_to edit_admin_item_types_transmit_and_proposal_path(proposal, :item_type_id => @vendor_schedule_setup.item_type_id) if !request.xhr?)
  end

  def update_as_built_vendor_schedule_setup
    @vendor_schedule_setup = VendorScheduleSetup.find params[:vendor_schedule_setup][:id] if params[:page] == "project"
    @vendor_schedule_setup = ItemTagVendorScheduleSetup.find params[:item_tag_vendor_schedule_setup][:id] if params[:page] == "item_tag"
    @vendor_schedule_setup.update_attributes params[:vendor_schedule_setup]
    if (params[:page] == "item_tag")
      @vendor_schedule_setup.as_built = params[:item_tag_vendor_schedule_setup][:as_built]
      @vendor_schedule_setup.save
    end
    (params[:page] == "project") ? (redirect_to edit_steps_admin_project_path(@vendor_schedule_setup.project_id, :step => "vendor_schedule_setup") if !request.xhr?) : (redirect_to edit_admin_item_types_transmit_and_proposal_path(proposal, :item_type_id => @vendor_schedule_setup.item_type_id) if !request.xhr?)
  end

  def update_with_shipment_vendor_schedule_setup
    @vendor_schedule_setup = VendorScheduleSetup.find params[:vendor_schedule_setup][:id] if params[:page] == "project"
    @vendor_schedule_setup = ItemTagVendorScheduleSetup.find params[:item_tag_vendor_schedule_setup][:id] if params[:page] == "item_tag"
    @vendor_schedule_setup.update_attributes params[:vendor_schedule_setup]
    if (params[:page] == "item_tag")
      @vendor_schedule_setup.with_shipment = params[:item_tag_vendor_schedule_setup][:with_shipment]
      @vendor_schedule_setup.save
    end
    (params[:page] == "project") ? (redirect_to edit_steps_admin_project_path(@vendor_schedule_setup.project_id, :step => "vendor_schedule_setup") if !request.xhr?) : (redirect_to edit_admin_item_types_transmit_and_proposal_path(proposal, :item_type_id => @vendor_schedule_setup.item_type_id) if !request.xhr?)
  end

  def update_request_for_quotation_setup
    @rfq_setup = RequestForQuotationSetup.find params[:request_for_quotation_setup][:id]
    #raise @rfq_setup.to_yaml
    @rfq_setup.update_attributes params[:request_for_quotation_setup]
    redirect_to edit_steps_admin_project_path(@rfq_setup.project_id, :step => "request_for_quotation_setup") if !request.xhr?
  end


  def quotation

    #raise params[:project_id].inspect
    #redirect_to edit_steps_admin_project_path(params[:project_id], :step => "vendor_schedule_setup", :item_id => params[:item_id])
    #render :partial => 'quotation'
    #redirect_to root_path

  end

  private

  #workaround for converting pipe roughtness values
  #inch to current project value
  def pipe_roughness_cf(project)
    cf = project.specified_units_cf(:mtype => "Length", :msub_type => "Small Dimension Length", :previous_unit => 'Inches')
    return {:factor => cf[:factor], :decimals => cf[:decimals]}
  end

  #workaround for sizing criteria values when creating
  #velocity ft/s to current project value
  #pressure psi to current project value
  def sizing_criteria_cf(project)
    vuom = project.specified_units_cf(:mtype => "Velocity", :msub_type => "General", :previous_unit => 'Feet per second')
    duom = project.specified_units_cf(:mtype => "Pressure", :msub_type => "Differential", :previous_unit => 'Pound per square inch')
    return {:vcf => vuom[:factor], :vdp => vuom[:decimals], :dcf => duom[:factor], :ddp => duom[:decimals]}
  end


end