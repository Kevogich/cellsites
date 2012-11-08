class Admin::HeatExchangerSizingsController < AdminController
#TODO Remove redundant code
  before_filter :default_form_values, :only => [:new, :create, :edit, :update]
  
  def index
    @heat_exchanger_sizings = @company.heat_exchanger_sizings.where(:process_unit_id => (user_project_setting.process_unit_id rescue 0))
    
    if @user_project_settings.client_id.nil?     
      flash[:error] = "Please Update Project Setting"      
      redirect_to admin_sizings_path
    end
  end
  
  def new
    @heat_exchanger_sizing = @company.heat_exchanger_sizings.new
  end
  
  def create
    heat_exchanger_sizing = params[:heat_exchanger_sizing]
    heat_exchanger_sizing[:created_by] = heat_exchanger_sizing[:updated_by] = current_user.id    
    @heat_exchanger_sizing = @company.heat_exchanger_sizings.new(heat_exchanger_sizing)
        
    if !@heat_exchanger_sizing.sd_process_basis_id.nil?
      heat_and_meterial_balance = HeatAndMaterialBalance.find(@heat_exchanger_sizing.sd_process_basis_id)
      @streams = heat_and_meterial_balance.heat_and_material_properties.first.streams
    end
    
    if @heat_exchanger_sizing.save
      @heat_exchanger_sizing.sizing_status_activities.create({:user_id => current_user.id, :status => 'new', :request_user_id => current_user.id})
      flash[:notice] = "New heat exchanger sizing created successfully."
      if !params[:calculate_btn].blank?
        redirect_to edit_admin_heat_exchanger_sizing_path(:id => @heat_exchanger_sizing.id, :calculate_btn => params[:calculate_btn], :anchor => params[:tab])
      else
        redirect_to admin_heat_exchanger_sizings_path
      end
    else
      render :new
    end
  end
  
  def edit
    @heat_exchanger_sizing = @company.heat_exchanger_sizings.find(params[:id])
    @project = @heat_exchanger_sizing.project
    if !@heat_exchanger_sizing.sd_process_basis_id.nil?
      heat_and_meterial_balance = HeatAndMaterialBalance.find(@heat_exchanger_sizing.sd_process_basis_id)
      @streams = heat_and_meterial_balance.heat_and_material_properties.first.streams
    end
  end
  
  def update
    heat_exchanger_sizing = params[:heat_exchanger_sizing]
    heat_exchanger_sizing[:updated_by] = current_user.id
    @heat_exchanger_sizing = @company.heat_exchanger_sizings.find(params[:id])
        
    if !@heat_exchanger_sizing.sd_process_basis_id.nil?
      heat_and_meterial_balance = HeatAndMaterialBalance.find(@heat_exchanger_sizing.sd_process_basis_id)
      @streams = heat_and_meterial_balance.heat_and_material_properties.first.streams
    end
        
    if @heat_exchanger_sizing.update_attributes(heat_exchanger_sizing)
      flash[:notice] = "Updated heat exchanger sizing successfully."
      if !params[:calculate_btn].blank?
        redirect_to edit_admin_heat_exchanger_sizing_path(:id => @heat_exchanger_sizing.id, :calculate_btn => params[:calculate_btn], :anchor => params[:tab])
      else
        redirect_to admin_heat_exchanger_sizings_path
      end
    else      
      render :edit
    end
  end
  
  def destroy
    @heat_exchanger_sizing = @company.heat_exchanger_sizings.find(params[:id])
    if @heat_exchanger_sizing.destroy
      flash[:notice] = "Deleted #{@heat_exchanger_sizing.exchanger_tag} successfully."
      redirect_to admin_heat_exchanger_sizings_path
    end
  end

  def clone
	  @heat_exchanger_sizing = @company.heat_exchanger_sizings.find(params[:id])
	  new = @heat_exchanger_sizing.clone :except => [:created_at, :updated_at]
	  new.exchanger_tag = params[:tag]
	  if new.save
		  render :json => {:error => false, :url => edit_admin_heat_exchanger_sizing_path(new) }
	  else
		  render :json => {:error => true, :msg => "Error in cloning.  Please try again!"}
	  end
	  return
  end
  
  def get_stream_values
    form_values = {}
    
    heat_and_meterial_balance = HeatAndMaterialBalance.find(params[:process_basis_id])    
    property = heat_and_meterial_balance.heat_and_material_properties
    
    pressure = property.where(:phase => "Overall", :property => "Pressure (absolute)").first    
    pressure_stream = pressure.streams.where(:stream_no => params[:stream_no]).first
    form_values[:pressure] = pressure_stream.stream_value.to_f rescue nil
    
    temperature = property.where(:phase => "Overall", :property => "Temperature").first
    temperature_stream = temperature.streams.where(:stream_no => params[:stream_no]).first
    form_values[:temperature] = temperature_stream.stream_value.to_f rescue nil

    liquid_flow_rate = property.where(:phase => "Light Liquid", :property => "Mass Flow").first
    liquid_flow_rate_stream = liquid_flow_rate.streams.where(:stream_no => params[:stream_no]).first
    form_values[:liquid_flow_rate] = liquid_flow_rate_stream.stream_value.to_f rescue nil

    liquid_density = property.where(:phase => "Light Liquid", :property => "Mass Density").first
    liquid_density_stream = liquid_density.streams.where(:stream_no => params[:stream_no]).first
    form_values[:liquid_density] = liquid_density_stream.stream_value.to_f rescue nil

    liquid_viscosity = property.where(:phase => "Light Liquid", :property => "Viscosity").first
    liquid_viscosity_stream = liquid_viscosity.streams.where(:stream_no => params[:stream_no]).first
    form_values[:liquid_viscosity] = liquid_viscosity_stream.stream_value.to_f rescue nil

    liquid_specific_heat_capacity = property.where(:phase => "Light Liquid", :property => "Mass Heat Capacity").first
    liquid_specific_heat_capacity_stream = liquid_specific_heat_capacity.streams.where(:stream_no => params[:stream_no]).first
    form_values[:liquid_specific_heat_capacity] = liquid_specific_heat_capacity_stream.stream_value.to_f rescue nil

    liquid_thermal_conductivity = property.where(:phase => "Light Liquid", :property => "Thermal Conductivity").first
    liquid_thermal_conductivity_stream = liquid_thermal_conductivity.streams.where(:stream_no => params[:stream_no]).first
    form_values[:liquid_thermal_conductivity] = liquid_thermal_conductivity_stream.stream_value.to_f rescue nil

    liquid_surface_tension = property.where(:phase => "Light Liquid", :property => "Surface Tension").first
    liquid_surface_tension_stream = liquid_surface_tension.streams.where(:stream_no => params[:stream_no]).first
    form_values[:liquid_surface_tension] = liquid_surface_tension_stream.stream_value.to_f rescue nil

    vapor_flow_rate = property.where(:phase => "Vapour", :property => "Mass Flow").first
    vapor_flow_rate_stream = vapor_flow_rate.streams.where(:stream_no => params[:stream_no]).first
    form_values[:vapor_flow_rate] = vapor_flow_rate_stream.stream_value.to_f rescue nil

    vapor_viscosity = property.where(:phase => "Vapour", :property => "Viscosity").first
    vapor_viscosity_stream = vapor_viscosity.streams.where(:stream_no => params[:stream_no]).first
    form_values[:vapor_viscosity] = vapor_viscosity_stream.stream_value.to_f rescue nil

    vapor_mw = property.where(:phase => "Light Liquid", :property => "Molecular Weight").first
    vapor_mw_stream = vapor_mw.streams.where(:stream_no => params[:stream_no]).first
    form_values[:vapor_mw] = vapor_mw_stream.stream_value.to_f rescue nil

    vapor_z = property.where(:phase => "Vapour", :property => "Actual Volume Flow").first
    vapor_z_stream = vapor_z.streams.where(:stream_no => params[:stream_no]).first
    form_values[:vapor_z] = vapor_z_stream.stream_value.to_f rescue nil

    vapor_specific_heat_capacity = property.where(:phase => "Light Liquid", :property => "Mass Heat Capacity").first
    vapor_specific_heat_capacity_stream = vapor_specific_heat_capacity.streams.where(:stream_no => params[:stream_no]).first
    form_values[:vapor_specific_heat_capacity] = vapor_specific_heat_capacity_stream.stream_value.to_f rescue nil

    vapor_thermal_conductivity = property.where(:phase => "Vapour", :property => "Thermal Conductivity").first
    vapor_thermal_conductivity_stream = vapor_thermal_conductivity.streams.where(:stream_no => params[:stream_no]).first
    form_values[:vapor_thermal_conductivity] = vapor_thermal_conductivity_stream.stream_value.to_f rescue nil

    render :json => form_values
  end
  
  def heat_exchanger_sizing_summary
    @heat_exchanger_sizings = @company.heat_exchanger_sizings.all    
  end
  
  def set_breadcrumbs
    super
    @breadcrumbs << { :name => 'Sizing', :url => admin_sizings_path }
    @breadcrumbs << { :name => 'Heat Exchanger Sizing', :url => admin_heat_exchanger_sizings_path }
  end

  def change_tube_od
    heat_exchanger_sizing = HeatExchangerSizing.find(params[:heat_exchanger_sizing_id])

    render :json =>  {:success => true }
  end
  
  private
  
  def default_form_values

    @heat_exchanger_sizing = @company.heat_exchanger_sizings.find(params[:id]) rescue @company.heat_exchanger_sizings.new
    @comments = @heat_exchanger_sizing.comments
    @new_comment = @heat_exchanger_sizing.comments.new

    @attachments = @heat_exchanger_sizing.attachments
    @new_attachment = @heat_exchanger_sizing.attachments.new
    
    @streams = []    
  end
end

