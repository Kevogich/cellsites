class Admin::ReliefRateCalculationViewsController < AdminController

  def view_generic
    scenario_identification = ScenarioIdentification.find(params[:id])
    @generic = scenario_identification.relief_rate_generic

    if @generic.nil?
      @generic = ReliefRateGeneric.create({:scenario_identification_id => scenario_identification.id})
      @generic.save
    end

    @comments = @generic.comments
    @new_comment = @generic.comments.new

    @attachments = @generic.attachments
    @new_attachment = @generic.attachments.new

    render :layout => false if request.xhr?
  end

  def save_generic
    generic = ReliefRateGeneric.find(params[:relief_rate_generic][:id])
    params[:relief_rate_generic].each  do |attr|
      generic[attr[0]] = attr[1]
    end
    generic.save

    scenario_identification = generic.scenario_identification
    scenario_identification.rc_pressure = generic.relief_pressure if scenario_identification.rc_pressure.nil?
    scenario_identification.rc_mass_flow_rate = generic.relief_rate if scenario_identification.rc_mass_flow_rate.nil?
    scenario_identification.save

    scenario_summary = scenario_identification.scenario_summary

    redirect_to scenario_identification_admin_relief_device_sizings_path(:scenario_summary_id => scenario_summary.id, :anchor => "scenario_calculation")
  end

end
