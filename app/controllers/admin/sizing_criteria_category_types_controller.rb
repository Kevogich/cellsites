class Admin::SizingCriteriaCategoryTypesController < AdminController
  
  def new
    @sizing_criteria_category = SizingCriteriaCategory.find(params[:sizing_criteria_category_id])
    @sizing_criteria_category_type = @sizing_criteria_category.sizing_criteria_category_types.new
    
    render :layout => false
  end  
  
  def create
    sizing_criteria_category_type = params[:sizing_criteria_category_type]
    sizing_criteria_category_type[:created_by] = sizing_criteria_category_type[:updated_by] = current_user.id
    
    @sizing_criteria_category_type = SizingCriteriaCategoryType.new(sizing_criteria_category_type)
    
    respond_to do |format|
      if @sizing_criteria_category_type.save
        format.js 
      else
        format.js 
      end
    end
  end
  
  def edit
     @sizing_criteria_category_type = SizingCriteriaCategoryType.find(params[:id])
     
      render :layout => false
  end
  
  def update
    sizing_criteria_category_type = params[:sizing_criteria_category_type]
    sizing_criteria_category_type[:updated_by] = current_user.id
    
    @sizing_criteria_category_type = SizingCriteriaCategoryType.find(params[:id])
    
    respond_to do |format|
      if @sizing_criteria_category_type.update_attributes(sizing_criteria_category_type)
        format.js 
      else
        format.js 
      end
    end 
  end
  
  def destroy
    sizing_criteria_category_type = SizingCriteriaCategoryType.find(params[:id])
    if sizing_criteria_category_type.destroy
      flash[:notice] = "Deleted #{sizing_criteria_category_type.name} successfully."
      redirect_to admin_sizing_criterias_path
    end    
  end
end
