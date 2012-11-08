class Admin::ClientsController < AdminController

  respond_to :html, :json

  before_filter :find_client, :only => [ :show, :edit, :update, :destroy ]

  def index   
    @clients = @company.clients
  end

  def show
  end

  def destroy
    @client.destroy
    flash[:notice] = "Client has been deleted"
    respond_to do |format|
      format.js
      format.html { redirect_to admin_clients_path }
    end
  end

  def new
    @client = Client.new
  end

  def create
    @client = @company.clients.new( params[:client] )
    if @client.save
      flash[:notice] = "Client has been created"
      redirect_to admin_clients_path
    else
      flash[:notice] = "Client can not be saved"
      render :new
    end
  end

  def edit
  end

  def update
    if @client.update_attributes( params[:client] )
      flash[:notice] = "Client has been updated"
      redirect_to admin_client_path( @client )
    else
      flash[:notice] = "Client can not be saved"
      render :edit
    end
  end


  def find_client
    @client = Client.find params[:id]
    unless @client
      # raise error!
    end
  end

  def projects
    @client = Client.find params[:id]
	@projects = @client.projects
  end

  def set_breadcrumbs
    super
    @breadcrumbs << { :name => 'Clients', :url => admin_clients_path }
  end
end

