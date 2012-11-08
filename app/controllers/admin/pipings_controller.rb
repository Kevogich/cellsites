class Admin::PipingsController < AdminController

  helper_method :pressure_type

  def index
    @pipeable_id = params[:pipeable_id]
    @pipeable_type = params[:pipeable_type].underscore
    @pipeable_obj = @pipeable_type.classify.constantize.find(@pipeable_id)

    @pipings = @pipeable_obj.pipings
    @piping = @pipeable_obj.pipings.new

    @pipe_size_unit = user_project_setting.project.unit("Length", "Small Dimension Length")

    render :layout => false if request.xhr?
  end

  def update
    @pipeable_id = params[:pipeable_id]
    @pipeable_type = params[:pipeable_type]
    @pipeable_obj = @pipeable_type.classify.constantize.find(@pipeable_id)
    @pipeable_obj.update_attributes(params[@pipeable_type])
  end


  private

  def pressure_type(pipeable_type)
    outlet_list = %w(scenario_identification)
    inlet_list = %w()

    if outlet_list.include?(pipeable_type)
      "outlet"
    elsif inlet_list.include?(pipeable_type)
      "inlet"
    end
  end
end
