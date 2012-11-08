class Admin::PipeRoughnessController < AdminController
  
  def index
    @pipe_roughnesses = Pipe.all 
  end
  
  def new
    @pipe_roughness = Pipe.new
  end
  
  def create
    pipe = params[:pipe]
    pipe[:company_id] = @company.id
    pipe[:created_by] = pipe[:updated_by] = current_user.id
    @pipe_roughness = Pipe.new(pipe)
    if @pipe_roughness.save
      redirect_to admin_pipe_roughness_path
    else
      render :new
    end
  end
  
  def edit
    @pipe_roughness = Pipe.find(params[:id])
  end
  
  def update
    @pipe_roughness = Pipe.find(params[:id])
    pipe = params[:pipe]
    pipe[:updated_by] = current_user.id
    if @pipe_roughness.update_attributes(pipe)
      redirect_to admin_pipe_roughness_path
    else
      render :edit
    end
  end
  
  def destroy
    @pipe_roughness = Pipe.find(params[:id])
    @pipe_roughness.delete
    redirect_to admin_pipe_roughness_path    
  end
end
