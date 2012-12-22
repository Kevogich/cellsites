class Admin::ScenarioSummaryViewDetailsController < AdminController

  # Hydraulic Expansions
  def view_hydraulic_expansions
    @scenario_identification = ScenarioIdentification.find(params[:scenario_identification_id])
    @scenario_summary = @scenario_identification.scenario_summary
    @relief_device_sizing = @scenario_summary.relief_device_sizing
    @scenario_hydraulic_expansion = @scenario_identification.scenario_hydraulic_expansion

    if @scenario_hydraulic_expansion.nil?

      @scenario_identification.build_scenario_hydraulic_expansion({
        :initial => @relief_device_sizing.sizing_status_activities.created_by,
        :date1   => @scenario_identification.created_at
                                                                  })
      @scenario_identification.save
      @scenario_hydraulic_expansion = @scenario_identification.scenario_hydraulic_expansion
    end

    render :layout => false if request.xhr?
  end

  def save_hydraulic_expansions
    @scenario_hydraulic_expansion = ScenarioHydraulicExpansion.find(params[:scenario_hydraulic_expansion][:id])

    d = params[:scenario_hydraulic_expansion][:date1].split("/")
    params[:scenario_hydraulic_expansion][:date1] = "#{d[2]}-#{d[0]}-#{d[1]}"

    (1..7).each do |i|
      params[:scenario_hydraulic_expansion]["sr_#{i}"] = nil if !params[:scenario_hydraulic_expansion]["sr_#{i}"].present?
    end

    @scenario_hydraulic_expansion.update_attributes(params[:scenario_hydraulic_expansion])

    #update scenario identification
    scenario_identification = @scenario_hydraulic_expansion.scenario_identification
    scenario_identification.applicability = @scenario_hydraulic_expansion.applicability
    scenario_identification.documentation_by = @scenario_hydraulic_expansion.determined_by
    scenario_identification[:comments] = @scenario_hydraulic_expansion.comments
    scenario_identification.save

    scenario_summary = scenario_identification.scenario_summary
    scenario_summary.applicability = scenario_identification.applicability
    scenario_summary.save

    #scenario analyze calculation
    if params[:calculate_btn] == "scenario_analyze"
      scenario_analyze
    end
  end

  private

  def scenario_analyze

    if @scenario_hydraulic_expansion.sr_1 == "no"
      @scenario_hydraulic_expansion.comments = "The system does not operate liquid full. Therefore, hydraulic expansion is not considered a credible scenario."
      @scenario_hydraulic_expansion.applicability = "No"
      @scenario_hydraulic_expansion.determined_by = "Software"
      @scenario_hydraulic_expansion.initial = current_user.name
      @scenario_hydraulic_expansion.save
      return
    else
      @scenario_hydraulic_expansion.comments = ""
      @scenario_hydraulic_expansion.applicability = ""
      @scenario_hydraulic_expansion.determined_by = "Software"
      @scenario_hydraulic_expansion.initial = current_user.name
    end

    if @scenario_hydraulic_expansion.sr_2 == "no"
      @scenario_hydraulic_expansion.comments = "There are no mechanisms in place to completely isolate the liquid full system. Therefore, hydraulic expansion is not considered a credible scenario."
      @scenario_hydraulic_expansion.applicability = "No"
      @scenario_hydraulic_expansion.determined_by = "Software"
      @scenario_hydraulic_expansion.initial = current_user.name
      @scenario_hydraulic_expansion.save
      return
    else
      @scenario_hydraulic_expansion.comments = ""
      @scenario_hydraulic_expansion.applicability = "Undefined"
      @scenario_hydraulic_expansion.determined_by = "Software"
      @scenario_hydraulic_expansion.initial = current_user.name
    end

    if @scenario_hydraulic_expansion.sr_3 == "no"
      @scenario_hydraulic_expansion.comments = "Adminstrative controls(i.e. carseal open, lock open, instruction signs, etc..) are in place to prevent the isolation of the liquid full system against continued heat input. Therefore, hydraulic expansion is not considered a credible scenario."
      @scenario_hydraulic_expansion.applicability = "No"
      @scenario_hydraulic_expansion.determined_by = "Software"
      @scenario_hydraulic_expansion.initial = current_user.name
      @scenario_hydraulic_expansion.save
      return
    else
      @scenario_hydraulic_expansion.comments = ""
      @scenario_hydraulic_expansion.applicability = "Undefined"
      @scenario_hydraulic_expansion.determined_by = "Software"
      @scenario_hydraulic_expansion.initial = current_user.name
    end

    if @scenario_hydraulic_expansion.sr_5 == "no"
      @scenario_hydraulic_expansion.comments = "The system is the hot side of an exchanger. Hydraulic expansion is not considered a credible scenario."
      @scenario_hydraulic_expansion.applicability = "No"
      @scenario_hydraulic_expansion.determined_by = "Software"
      @scenario_hydraulic_expansion.initial = current_user.name
      @scenario_hydraulic_expansion.save
      return
    else
      @scenario_hydraulic_expansion.comments = ""
      @scenario_hydraulic_expansion.applicability = ""
      @scenario_hydraulic_expansion.determined_by = "Software"
      @scenario_hydraulic_expansion.initial = current_user.name
    end

=begin
    if @scenario_hydraulic_expansion.sr_6 == "yes"
      @scenario_hydraulic_expansion.comments = "The exchanger(s) is a process-process exchanger with the same fluid stream going through the hot side and the cold side, such that the blocking in of the cold side will also lead to the loss of hot side flow, resulting in the loss of heat transfer. Therefore, hydraulic expansion is not considered a credible scenario."
      @scenario_hydraulic_expansion.applicability = "No"
      @scenario_hydraulic_expansion.determined_by = "Software"
      @scenario_hydraulic_expansion.initial = current_user.name
      @scenario_hydraulic_expansion.save
      return
    else
      @scenario_hydraulic_expansion.comments = ""
      @scenario_hydraulic_expansion.applicability = ""
      @scenario_hydraulic_expansion.determined_by = "Software"
      @scenario_hydraulic_expansion.initial = current_user.name
    end
=end

    if @scenario_hydraulic_expansion.sr_6 == "no"
      @scenario_hydraulic_expansion.comments = "The exchanger(s) can be blocked in against continued heat input from the hot side. There are no administrative controls in place to prevent the isolation of the cold side against continued hot side flow; therefore, hydraulic expansion of the liquid inventory may result in overpressure."
      @scenario_hydraulic_expansion.applicability = "Applicable"
      @scenario_hydraulic_expansion.determined_by = "Software"
      @scenario_hydraulic_expansion.initial = current_user.name
      @scenario_hydraulic_expansion.save
      return
    else
      @scenario_hydraulic_expansion.comments = ""
      @scenario_hydraulic_expansion.applicability = ""
      @scenario_hydraulic_expansion.determined_by = "Software"
      @scenario_hydraulic_expansion.initial = current_user.name
    end

    #raise @scenario_hydraulic_expansion.sr_7.to_yaml

    if @scenario_hydraulic_expansion.sr_7 == "yes"
      @scenario_hydraulic_expansion.comments = "The liquid full system can be blocked in against continued heat input from heat tracing, heat coil, ambient heat gains or fire. There are no administrative controls in place to prevent the isolation of the liquid full system against continued hot side flow; therefore, hydraulic expansion of the liquid inventory may result in overpressure."
      @scenario_hydraulic_expansion.applicability = "Yes"
      @scenario_hydraulic_expansion.determined_by = "Software"
      @scenario_hydraulic_expansion.initial = current_user.name
      @scenario_hydraulic_expansion.save
      return
    else
      @scenario_hydraulic_expansion.comments = ""
      @scenario_hydraulic_expansion.applicability = ""
      @scenario_hydraulic_expansion.determined_by = "Software"
      @scenario_hydraulic_expansion.initial = current_user.name
    end

    if @scenario_hydraulic_expansion.sr_7 == "no"
      @scenario_hydraulic_expansion.comments = "The liquid full system can be blocked in but there is no identifiable and credible source of heat (i.e. heat tracing, heat coil, ambient heat gains or fire). Therefore, hydraulic expansion is not considered a credible scenario."
      @scenario_hydraulic_expansion.applicability = "No"
      @scenario_hydraulic_expansion.determined_by = "Software"
      @scenario_hydraulic_expansion.initial = current_user.name
      @scenario_hydraulic_expansion.save
      return
    else
      @scenario_hydraulic_expansion.comments = ""
      @scenario_hydraulic_expansion.applicability = ""
      @scenario_hydraulic_expansion.determined_by = "Software"
      @scenario_hydraulic_expansion.initial = current_user.name
    end

    @scenario_hydraulic_expansion.save
  end

end
