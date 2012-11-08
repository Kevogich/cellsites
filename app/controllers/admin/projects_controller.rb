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
