class Admin::ColumnSizingsController < AdminController

  #TODO Remove redundant code
  before_filter :default_form_values, :only => [:new, :create, :edit, :update]

  def index
    @column_sizings = @company.column_sizings.where(:process_unit_id => (user_project_setting.process_unit_id rescue 0))

    if @user_project_settings.client_id.nil?
      flash[:error] = "Please Update Project Setting"
      redirect_to admin_sizings_path
    end
  end

  def new
    @column_sizing = @company.column_sizings.new
    6.times do
      column_tray_specification = @column_sizing.column_tray_specifications.build
    end
  end

  def create
    column_sizing = params[:column_sizing]
    column_sizing[:created_by] = column_sizing[:updated_by] = current_user.id
    @column_sizing = @company.column_sizings.new(column_sizing)

    if !@column_sizing.sd_process_basis_id.nil?
      heat_and_material_balance = HeatAndMaterialBalance.find(@column_sizing.sd_process_basis_id)
      @streams = heat_and_material_balance.heat_and_material_properties.first.streams
    end

    if @column_sizing.save
      @column_sizing.sizing_status_activities.create({:user_id => current_user.id, :status => 'new', :request_user_id => current_user.id})
      flash[:notice] = "New column sizing created successfully."
      if params[:calculate_btn].blank?
        redirect_to admin_column_sizings_path
      else
        redirect_to edit_admin_column_sizing_path(@column_sizing, :anchor => params[:tab], :calculate_btn => params[:calculate_btn])
      end
    else
      params[:calculate_btn] = ''
      render :new
    end
  end

  def edit
    @column_sizing = @company.column_sizings.find(params[:id])

    if !@column_sizing.sd_process_basis_id.nil?
      heat_and_material_balance = HeatAndMaterialBalance.find(@column_sizing.sd_process_basis_id)
      @streams = heat_and_material_balance.heat_and_material_properties.first.streams
    end
  end

  def update
    column_sizing = params[:column_sizing]
    column_sizing[:updated_by] = current_user.id
    @column_sizing = @company.column_sizings.find(params[:id])

    if !@column_sizing.sd_process_basis_id.nil?
      heat_and_material_balance = HeatAndMaterialBalance.find(@column_sizing.sd_process_basis_id)
      @streams = heat_and_material_balance.heat_and_material_properties.first.streams
    end

    if @column_sizing.update_attributes(column_sizing)
      flash[:notice] = "Updated column sizing successfully."
      if params[:calculate_btn].blank?
        redirect_to admin_column_sizings_path
      else
        redirect_to edit_admin_column_sizing_path(@column_sizing, :anchor => params[:tab], :calculate_btn => params[:calculate_btn])
      end
    else
      params[:calculate_btn] = ''
      render :edit
    end
  end

  def destroy
    @column_sizing = @company.column_sizings.find(params[:id])
    if @column_sizing.destroy
      flash[:notice] = "Deleted #{@column_sizing.column_system} successfully."
      redirect_to admin_column_sizings_path
    end
  end

  def clone
	  @column_sizing = @company.column_sizings.find(params[:id])
	  new = @column_sizing.clone :except => [:created_at, :updated_at]
	  new.column_system = params[:tag]
	  if new.save
		  render :json => {:error => false, :url => edit_admin_column_sizing_path(new) }
	  else
		  render :json => {:error => true, :msg => "Error in cloning.  Please try again!"}
	  end
	  return
  end

  def get_stream_values
    form_values = {}

    heat_and_material_balance = HeatAndMaterialBalance.find(params[:process_basis_id])
    property = heat_and_material_balance.heat_and_material_properties

    pressure = property.where(:phase => "Overall", :property => "Pressure (absolute)").first
    pressure_stream = pressure.streams.where(:stream_no => params[:stream_no]).first
    form_values[:pressure] = pressure_stream.stream_value.to_f rescue nil

    temperature = property.where(:phase => "Overall", :property => "Temperature").first
    temperature_stream = temperature.streams.where(:stream_no => params[:stream_no]).first
    form_values[:temperature] = temperature_stream.stream_value.to_f rescue nil

    render :json => form_values
  end

  def column_sizing_summary
    @column_sizings = @company.column_sizings.all
  end

  def set_breadcrumbs
    super
    @breadcrumbs << {:name => 'Sizing', :url => admin_sizings_path}
    @breadcrumbs << {:name => 'Column Sizing', :url => admin_column_sizings_path}
  end

=begin
  def system_definition_calculation
    column_sizing = ColumnSizing.find(params[:column_sizing_id])
    project = column_sizing.project

    #Determined column pressure drop
    top_pressure = column_sizing.sd_pressure_4
    bottom_pressure = column_sizing.sd_pressure_2
    column_dp = bottom_pressure - top_pressure
    column_sizing.sd_column_dp = column_dp.round(4)

    #Determine static head
    liquid_level = column_sizing.sd_max_liquid_level
    vessel_density = column_sizing.sd_bottom_density

    static_pressure = liquid_level / (144.0 / vessel_density) #Head in psi

    column_sizing.sd_static_pressure = static_pressure.round(2)

    column_sizing.save

    render :json => {:success => true}
  end
=end

  def minimum_column_stages_calculation
    column_sizing = ColumnSizing.find(params[:column_sizing_id])
    project = column_sizing.project
    column_sizing.update_attributes(params[:column_sizing])

    basis = column_sizing.cd_mcs_basis
    lk_distillate = column_sizing.cd_mcs_moles_of_lk_in_distillate
    hk_distillate = column_sizing.cd_mcs_moles_of_hk_in_distillate
    lk_bottoms = column_sizing.cd_mcs_moles_of_lk_in_bottoms

    hk_bottoms = column_sizing.cd_mcs_moles_of_hk_in_bottoms

    if column_sizing.cd_mcs_basis == "molar_flowrate"
      separation_factor = (lk_distillate / hk_distillate) * (hk_bottoms / lk_bottoms)
      column_sizing.cd_mcs_separation_factor = separation_factor.round(2)
    elsif column_sizing.cd_mcs_basis == "molar_fraction"
      separation_factor = (lk_distillate / lk_bottoms) * (hk_bottoms / hk_distillate)
      column_sizing.cd_mcs_separation_factor = separation_factor.round(2)
    end

    #Determine mean relative volatility
    top_volatility = column_sizing.cd_mcs_relative_volatility_top
    bottom_volatility = column_sizing.cd_mcs_relative_volatility_bottom
    feed_volatility = column_sizing.cd_mcs_relative_volatility_feed

    if feed_volatility != 0
      average_volatility = (top_volatility * feed_volatility * bottom_volatility) ** (1.0 / 3.0)
      column_sizing.cd_mcs_mean_relative_volatility = average_volatility.round(3)
    else
      average_volatility = (top_volatility * bottom_volatility) ** (1.0 / 2.0)
      column_sizing.cd_mcs_mean_relative_volatility = average_volatility.round(3)
    end

    #Determine the minimum number of stages required for separation
    part1 = Math.log(separation_factor) / Math.log(10)
    part2 = Math.log(average_volatility) / Math.log(10)

    min_stage = part1 / part2

    column_sizing.cd_mcs_minimum_stages = min_stage.round(2)

    column_sizing.save

    render :json => {:success => true, :column_sizing => column_sizing}
  end

  def minimum_column_stages_winn_modified_calculation
    column_sizing = ColumnSizing.find(params[:column_sizing_id])
    project = column_sizing.project
    column_sizing.update_attributes(params[:column_sizing])

    b = column_sizing.cd_win_exponential_b
    klk = column_sizing.cd_win_equilibrium_k_value_light_key
    khk = column_sizing.cd_win_equilibrium_k_value_heavy_key

    bottoms = column_sizing.cd_win_bottom_product_rate_b
    distillate = column_sizing.cd_win_distillate_product_rate_d
    xdlk = column_sizing.cd_mcs_moles_of_lk_in_distillate.to_f + 0
    xdhk = column_sizing.cd_mcs_moles_of_hk_in_distillate.to_f + 0
    xblk = column_sizing.cd_mcs_moles_of_lk_in_bottoms.to_f + 0
    xbhk = column_sizing.cd_mcs_moles_of_hk_in_bottoms.to_f + 0

    bij = klk / khk ** b

    part1 = (xdlk / xblk) * (xbhk / xdhk) ** b
    part2 = (bottoms / distillate) ** (1 - b)
    part3 = Math.log(part1 * part2) / Math.log(10)
    part4 = Math.log(bij) / Math.log(10)

    minimum_stage = part3 / part4

    column_sizing.cd_win_minimum_stages = minimum_stage.round(2) rescue 0.0

    column_sizing.save

    render :json => {:success => true, :column_sizing => column_sizing}
  end

  def minimum_reflux_ratio_calculation
    column_sizing = ColumnSizing.find(params[:column_sizing_id])
    project = column_sizing.project
    column_sizing.update_attributes(params[:column_sizing])
    column_sizing.save

    column_sizing = ColumnSizing.find(params[:column_sizing_id])

    xf = []
    xd = []
    alpha = []
    k_value = []
    theta_value = []
    sum_parts = []
    alpha_lk = 0
    lk_count = 0
    alpha_hk = 0
    hk_count = 0

    minimum_reflux_ratios = column_sizing.minimum_reflux_ratios
    mrr_count = minimum_reflux_ratios.size

    rs_basis_k_value = column_sizing.minimum_reflux_ratios.where("basis = ?", 1).first
    basis_k_value = rs_basis_k_value.k_value_feed

    minimum_reflux_ratios.each_with_index do |mrr, i|
      if !mrr.k_value_feed.nil? && mrr.k_value_feed != 0
        k_value[i] = mrr.k_value_feed
        alpha[i] = k_value[i] / basis_k_value
        mrr.relative_volatility = alpha[i]
        mrr.save
      end

      xf[i] = mrr.feed_mole
      xd[i] = mrr.distillate_mole

      #Determine if the light key is adjacent to the heavy key
      if mrr.lk == true
        alpha_lk = alpha[i]
        lk_count = lk_count + 1
      end

      if mrr.hk == true
        alpha_hk = alpha[i]
        hk_count = hk_count + 1
      end
    end

    q = column_sizing.cd_mrr_liquid_mole_fraction_of_feed
    part1 = (1 - q)

    component_count = column_sizing.cd_mrr_component_count.to_i

    theta = 0
    if (hk_count - lk_count) == 0

    elsif (hk_count - lk_count) < 0

    elsif (hk_count - lk_count) > 1

    elsif (hk_count - lk_count) == 1
      increment = (alpha_lk.to_f - alpha_hk.to_f).abs / 1000.0
      mrr_count.times do |j|
        sum_part2 = 0

        component_count.times do |i|
          theta_value[j] = alpha_hk.to_f + (j * increment)
          part2 = xf[i] / ((alpha[i].to_f - theta_value[j]) / alpha[i]) rescue 0
          sum_part2 = sum_part2 + part2
          sum_parts[j] = sum_part2
        end

        if sum_parts[j] < 0 && sum_parts[j - 1] > 0
          theta = theta_value[j]
          break
        elsif sum_parts[j] > 0 && sum_parts[j - 1] < 0
          theta = theta_value[j]
          break
        end
      end
    end

    column_sizing.cd_mrr_theta = theta.round(2)

    #Determine minimum Reflux Ratio
    sum_part3 = 0
    component_count.times do |ii|
      if xd[ii] != "" && !alpha[ii].nil?
        part3 = (xd[ii] * alpha[ii].to_f) / (alpha[ii].to_f - theta)
        sum_part3 = sum_part3 + part3
      end
    end

    rmin = sum_part3 - 1

    column_sizing.cd_mrr_minimum_reflux_ratio = rmin.round(3)

    column_sizing.cd_minimum_reflux_ratio = rmin.round(3)
    column_sizing.save

    render :json => {:success => true, :column_sizing => column_sizing}
  end

  private

  def default_form_values
    @column_sizing = @company.column_sizings.find(params[:id]) rescue @company.column_sizings.new
    @comments = @column_sizing.comments
    @new_comment = @column_sizing.comments.new

    @attachments = @column_sizing.attachments
    @new_attachment = @column_sizing.attachments.new

    @streams = []
  end

end
