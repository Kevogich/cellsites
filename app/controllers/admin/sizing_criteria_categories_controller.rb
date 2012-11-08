class Admin::SizingCriteriaCategoriesController < AdminController
  
  def new
    @sizing_criteria_category = @company.sizing_criteria_categories.new
    
    render :layout => false
  end
  
  def create
    sizing_criteria_category = params[:sizing_criteria_category]
    sizing_criteria_category[:created_by] = sizing_criteria_category[:updated_by] = current_user.id    
    @sizing_criteria_category = SizingCriteriaCategory.new(sizing_criteria_category)
    
    respond_to do |format|
      if @sizing_criteria_category.save
        format.js 
      else
        format.js 
      end
    end    
  end
  
  def edit
    @sizing_criteria_category = @company.sizing_criteria_categories.find(params[:id])
    
    render :layout => false
  end
  
  def update
    sizing_criteria_category = params[:sizing_criteria_category]
    sizing_criteria_category[:updated_by] = current_user.id
    
    @sizing_criteria_category = @company.sizing_criteria_categories.find(params[:id])
    
    respond_to do |format|
      if @sizing_criteria_category.update_attributes(sizing_criteria_category)
        format.js 
      else
        format.js 
      end
    end 
    
  end
    
  def destroy
    sizing_criteria_category = @company.sizing_criteria_categories.find(params[:id])
    if sizing_criteria_category.destroy
      flash[:notice] = "Deleted #{sizing_criteria_category.name} successfully."
      redirect_to admin_sizing_criterias_path
    end    
  end
  
end
