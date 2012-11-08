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
    scenario_hydraulic_expansion = ScenarioHydraulicExpansion.find(params[:scenario_hydraulic_expansion][:id])

    d = params[:scenario_hydraulic_expansion][:date1].split("/")
    params[:scenario_hydraulic_expansion][:date1] = "#{d[2]}-#{d[0]}-#{d[1]}"

    scenario_hydraulic_expansion.update_attributes(params[:scenario_hydraulic_expansion])

    #update scenario identification
    scenario_identification = scenario_hydraulic_expansion.scenario_identification
    scenario_identification.applicability = scenario_hydraulic_expansion.applicability
    scenario_identification.documentation_by = scenario_hydraulic_expansion.determined_by
    scenario_identification[:comments] = scenario_hydraulic_expansion.comments
    scenario_identification.save

    scenario_summary = scenario_identification.scenario_summary
    scenario_summary.applicability = scenario_identification.applicability
    scenario_summary.save
  end
end
