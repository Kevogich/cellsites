class Admin::ProcuresController < AdminController
  before_filter :default_form_values, :only => [:new, :create, :edit, :update, :index]

  def index
    @procure_rfq_sections = ProcureRfqSection.all
    @procure_additional_po_costs = ProcureAdditionalPoCost.all
  end

  def procure_rfq_sections
    @procure_rfq_section = ProcureRfqSection.new
    @procure_rfq_section.name = params[:name]
    if @procure_rfq_section.save
      redirect_to admin_procures_path
      flash[:notice] ="Rfq Section created successfully"
    else
      redirect_to admin_procures_path
      flash[:error] ="Please mention the Rfq Section name"
    end
  end

  def procure_rfq_sections_destroy
    ProcureRfqSection.find(params[:id]).destroy
    redirect_to admin_procures_path
    flash[:notice] = "Rfq Section deleted successfully"
  end

  def procure_additional_po_costs
    @procure_additional_po_cost = ProcureAdditionalPoCost.new
    @procure_additional_po_cost.name = params[:name]
    if @procure_additional_po_cost.save
      redirect_to admin_procures_path
      flash[:notice] ="Additional Po Cost created successfully"
    else
      redirect_to admin_procures_path
      flash[:error] ="Please mention the Additional Po Cost name"
    end
  end

  def procure_additional_po_costs_destroy
    ProcureAdditionalPoCost.find(params[:id]).destroy
    redirect_to admin_procures_path
    flash[:notice] = "Additional Po Cost deleted successfully"
  end



  def set_breadcrumbs
    super
    @breadcrumbs << {:name => 'Procure', :url => admin_procures_path}
  end

  def default_form_values

    @procure = Procure.find(params[:id]) rescue Procure.new

    @comments = @procure.comments
    @new_comment = @procure.comments.new

    @attachments = @procure.attachments
    @new_attachment = @procure.attachments.new

  end


end
