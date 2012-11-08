class Admin::GroupsController < AdminController

  respond_to :html, :json

  before_filter :find_group, :only => [ :show, :edit, :update, :destroy ]

  def destroy
    @group.destroy
    flash[:notice] = "Group has been deleted"
    respond_to do |format|
      format.js
      format.html { redirect_to admin_groups_path }
    end
  end

  def new
    @group = Group.new
  end

  def create
    @group = @company.groups.new( params[:group] )
    if @group.save
      flash[:notice] = "Group has been created"
      respond_to do |format|
        format.js
        format.html { redirect_to admin_groups_path }
      end
    else
      flash[:notice] = "Group can not be saved"
      respond_to do |format|
        format.js
        format.html { render :new }
      end
    end
  end

  def find_group
    @group = Group.find params[:id]
    unless @group
      # raise error!
    end
  end

end

