class Admin::TitlesController < AdminController

  respond_to :html, :json

  before_filter :find_title, :only => [ :show, :edit, :update, :destroy ]

  def destroy
    @title.destroy
    flash[:notice] = "Title has been deleted"
    respond_to do |format|
      format.js
      format.html { redirect_to admin_titles_path }
    end
  end

  def new
    @title = Title.new
  end

  def create
    @title = @company.titles.new( params[:title] )
    if @title.save
      flash[:notice] = "Title has been created"
      respond_to do |format|
        format.js
        format.html { redirect_to admin_titles_path }
      end
    else
      flash[:notice] = "Title can not be saved"
      respond_to do |format|
        format.js
        format.html { render :new }
      end
    end
  end

  def find_title
    @title = Title.find params[:id]
    unless @title
      # raise error!
    end
  end

end

