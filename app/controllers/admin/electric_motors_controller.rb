class Admin::ElectricMotorsController < AdminController
  #TODO Remove redundant code
  before_filter :default_form_values, :only => [:new, :create, :edit, :update]
  
  def new
    @electric_motor = @company.electric_motors.new   
  end
  
  def create
    electric_motor = params[:electric_motor]
    electric_motor[:created_by] = electric_motor[:updated_by] = current_user.id    
    @electric_motor = @company.electric_motors.new(electric_motor)    
    
    if @electric_motor.save
      @electric_motor.sizing_status_activities.create({:user_id => current_user.id, :status => 'new', :request_user_id => current_user.id})
      flash[:notice] = "New electric motor created successfully."
      redirect_to admin_driver_sizings_path(:anchor => "electric_motor")
    else
      render :new
    end
  end
  
  def edit
    @electric_motor = @company.electric_motors.find(params[:id])

    @latest_status = @electric_motor.sizing_status_activities.latest_status

    unless @electric_motor.equipment_type.nil?
      param = {:equipment_type => @electric_motor.equipment_type,:project_id => @user_project_settings.project_id}
      @equipment_tags = get_equipment_tags(param)
    end
  end
  
  def update
    electric_motor = params[:electric_motor]
    electric_motor[:updated_by] = current_user.id    
    @electric_motor = @company.electric_motors.find(params[:id])

    unless electric_motor[:equipment_type].nil?
      param = {:equipment_type => @electric_motor.equipment_type,:project_id => @user_project_settings.project_id}
      @equipment_tags = get_equipment_tags(param)
    end
        
    if @electric_motor.update_attributes(electric_motor)
      flash[:notice] = "Updated electric motor successfully."
      redirect_to admin_driver_sizings_path(:anchor => "electric_motor")
    else      
      render :edit
    end
  end
  
  def destroy
    @electric_motor = @company.electric_motors.find(params[:id])
    if @electric_motor.destroy
      flash[:notice] = "Deleted #{@electric_motor.electric_motor_tag} successfully."
      redirect_to admin_driver_sizings_path(:anchor => "electric_motor")
    end
  end

  def clone
      @electric_motor = @company.electric_motors.find(params[:id])
	  new = @electric_motor.clone :except => [:created_at, :updated_at]
	  new.electric_motor_tag = params[:tag]
	  if new.save
		  render :json => {:error => false, :url => edit_admin_electric_motor_path(new) }
	  else
		  render :json => {:error => true, :msg => "Error in cloning.  Please try again!"}
	  end
	  return
  end

  def electric_motor_summary
    @electric_motors = @company.electric_motors.all    
  end
  
  def get_equiment_tag_by_equiment_type
	  render :json => get_equipment_tags(params)
  end

  def get_rotating_equipment_details
    equipment_details = {}    
    equipment_type = params[:equipment_type]
    equipment_tag = params[:equipment_tag]
    
    #TODO re-check mappings
    if equipment_type == "Centrifugal Pump" || equipment_type == "Reciprocating Pump"      
      pump_sizing = PumpSizing.find(equipment_tag)
      if equipment_type == "Centrifugal Pump"
        equipment_details[:capacity] = pump_sizing.cd_flow_rate
        equipment_details[:differential_pressure] = pump_sizing.cd_differential_pressure
        equipment_details[:horsepower] = pump_sizing.cd_brake_horsepower
        equipment_details[:speed] = ""
      elsif equipment_type == "Reciprocating Pump"
        equipment_details[:capacity] = pump_sizing.rd_rated_discharge_capacity
        equipment_details[:differential_pressure] = pump_sizing.rd_differential_pressure
        equipment_details[:horsepower] = pump_sizing.rd_brake_horsepower
        equipment_details[:speed] = ""
      end
    elsif equipment_type == "Centrifugal Compressor" || equipment_type == "Reciprocating Compressor"
       compressor_sizing = CompressorSizing.find(equipment_tag)        
       if equipment_type == "Centrifugal Compressor"
         equipment_details[:capacity] = ""
         equipment_details[:differential_pressure] = compressor_sizing.cd_overall_differential_pressure
         equipment_details[:horsepower] = ""
         equipment_details[:speed] = ""
       elsif equipment_type == "Reciprocating Compressor"
         equipment_details[:capacity] = ""
         equipment_details[:differential_pressure] = compressor_sizing.rd_overall_differential_pressure
         equipment_details[:horsepower] = ""
         equipment_details[:speed] = ""
       end
    end
    respond_to do |format|
      format.json {render :json => equipment_details}     
    end
  end


  def set_breadcrumbs
    super
    @breadcrumbs << { :name => 'Driver Sizing', :url => admin_driver_sizings_path }
    @breadcrumbs << { :name => 'Electric Motor', :url => admin_driver_sizings_path(:anchor => "electric_motor")}
  end

  
  private
  
  def default_form_values

    @electric_motor = @company.electric_motors.find(params[:id]) rescue @company.electric_motors.new
    @comments = @electric_motor.comments
    @new_comment = @electric_motor.comments.new

    @attachments = @electric_motor.attachments
    @new_attachment = @electric_motor.attachments.new

    @project = @user_project_settings.project
    @streams = []    
	  @equipment_tags = []
  end

  def get_equipment_tags(params)
	  equipment_type = params[:equipment_type]    
	  project = Project.find(params[:project_id])
	  equipment_tag = []       
	  if equipment_type == "Centrifugal Pump" || equipment_type == "Reciprocating Pump"      
		  rs_pump_sizings = project.pump_sizings     getgetget
		  rs_pump_sizings.each do |rs_pump_sizing|
			  equipment_tag << {:id => rs_pump_sizing.id, :tag => rs_pump_sizing.centrifugal_pump_tag}
		  end
	  elsif equipment_type == "Centrifugal Compressor" || equipment_type == "Reciprocating Compressor"      
		  rs_compressor_sizing_tags = project.compressor_sizing_tags
		  rs_compressor_sizing_tags.each do |rs_compressor_sizing_tag|        
			  rs_compressor_sizing = rs_compressor_sizing_tag.compressor_sizings.where(:selected_sizing => true).first                
			  equipment_tag << {:id => rs_compressor_sizing.id, :tag => rs_compressor_sizing_tag.compressor_sizing_tag} if !rs_compressor_sizing.nil?
		  end      
	  end
	  return equipment_tag
  end

end
