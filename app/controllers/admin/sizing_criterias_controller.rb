class Admin::SizingCriteriasController < AdminController
  
  def index
    @sizing_criteria_categoires = @company.sizing_criteria_categories    
  end
  
  def new   
    @sizing_criteria_category_type = SizingCriteriaCategoryType.find(params[:sizing_criteria_category_type_id])
    @sizing_criteria = @sizing_criteria_category_type.sizing_criterias.new()
    @sizing_criteria.sizing_criteria_category_id = @sizing_criteria_category_type.sizing_criteria_category.id    
    render :layout => false
  end
  
  def create
    sizing_criteria = params[:sizing_criteria]
    sizing_criteria[:created_by] = sizing_criteria[:updated_by] = current_user.id
    @sizing_criteria = SizingCriteria.new(sizing_criteria)    
    respond_to do |format|
      if @sizing_criteria.save
        format.js 
      else
        format.js 
      end
    end     
  end
  
  def show
    
  end
  
  def edit
    @sizing_criteria = SizingCriteria.find(params[:id])
    
    render :layout => false
  end
  
  def update
    sizing_criteria = params[:sizing_criteria]
    sizing_criteria[:updated_by] = current_user.id
    
    @sizing_criteria = SizingCriteria.find(params[:id])
    
    respond_to do |format|
      if @sizing_criteria.update_attributes(sizing_criteria)
        format.js 
      else
        format.js 
      end
    end
  end
  
  def destroy
    sizing_criteria = SizingCriteria.find(params[:id])
    if sizing_criteria.destroy
      flash[:notice] = "Deleted #{sizing_criteria.name} successfully."
      redirect_to admin_sizing_criterias_path
    end 
  end
  
  def show_sizing_criterias
    
    project_id = params[:project_id]
    
    @sizing_criteria_categories = @company.sizing_criteria_categories
    @sizing_criterias = {}
    
    @sizing_criteria_categories.each do |sizing_criteria_category|
      @sizing_criterias[sizing_criteria_category.id.to_s] = sizing_criteria_category.sizing_criterias
    end
    
    @project_sizing_criteria = ProjectSizingCriteria.where(:project_id => project_id)
            
    render :layout => false
  end
  
  def add_sizing_criterias_to_project
    @sizing_criteria =  SizingCriteria.find(params[:id])
    project_id = params[:project_id]
    
    psc = {
      :project_id => project_id,
      :sizing_criteria_category_id => @sizing_criteria.sizing_criteria_category_id,
      :sizing_criteria_id => @sizing_criteria.id,
      :velocity_min => @sizing_criteria.velocity_min,
      :velocity_max => @sizing_criteria.velocity_max,
      :velocity_sel => @sizing_criteria.velocity_sel,
      :delta_per_100ft_min => @sizing_criteria.delta_per_100ft_min,
      :delta_per_100ft_max => @sizing_criteria.delta_per_100ft_max,
      :delta_per_100ft_sel => @sizing_criteria.delta_per_100ft_sel,
      :user_notes => @sizing_criteria.user_notes,
      :created_by => current_user.id,
      :updated_by => current_user.id      
    }
    
    @project_sizing_criteria = ProjectSizingCriteria.new(psc)
    
    if @project_sizing_criteria.save
      flash[:notice] = "Added Sizing Criteria Succcessfully."
    end
    
  end
  
  def set_breadcrumbs
    super    
    @breadcrumbs << { :name => 'Sizing Criteria', :url => admin_sizing_criterias_path }
  end
end
