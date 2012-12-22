class Admin::MechanicalSpecificationsController < AdminController


  def index
    @itemtypes = ItemType.where(:company_id => current_user.id )
    @vendor_requirements = VendorDataRequirement.all
    @datasheets =Datasheet.where(:company_id => current_user.id )
  end

  def itemtypes
    @itemtype = ItemType.new
    @itemtype.item_type = params[:item_type]
    @itemtype.company_id = current_user.id
    if @itemtype.save
      redirect_to admin_mechanical_specifications_path
      flash[:notice] ="Item type created successfully"
    else
      redirect_to admin_mechanical_specifications_path
      flash[:error] ="Please mention the Item Type"
    end
  end

  def vendor_requirement
    @vendor_requirement = VendorDataRequirement.new
    @vendor_requirement.vendor_data_requirement= params[:vendor_requirement]

    if @vendor_requirement.save
    redirect_to admin_mechanical_specifications_path
    flash[:notice] ="Vendor Data requirement created successfully"
    else
      redirect_to admin_mechanical_specifications_path
      flash[:error] ="Please mention the Vendor Data requirement "
    end
  end
  def datasheet
    #raise "check"
    @datasheet = Datasheet.new
    @datasheet.datasheet_name = params[:datasheet]
    @datasheet.item_type_id = params[:item_type_datasheet]
    @datasheet.company_id = current_user.id
    if @datasheet.save
      redirect_to admin_mechanical_specifications_path
      flash[:notice] ="Data sheet created successfully"
    else
      redirect_to admin_mechanical_specifications_path
      flash[:error] ="Please mention the Datasheet "
    end
  end

  def itemtypes_destroy

    ItemType.find(params[:type_id]).destroy
    redirect_to admin_mechanical_specifications_path
    flash[:notice] = "Item type deleted successfully"
  end

  def vendor_requirement_destroy
    VendorDataRequirement.find(params[:req_id]).destroy
    redirect_to admin_mechanical_specifications_path
    flash[:notice] = "Vendor Data Requirement deleted successfully"
  end
  def datasheet_destroy
    Datasheet.find(params[:datasheet_id]).destroy
    redirect_to admin_mechanical_specifications_path
    flash[:notice] = "Datasheet deleted successfully"
  end
   def datasheet_item_type
     raise "check"
   end
  def set_breadcrumbs
    super
    @breadcrumbs << {:name => 'Mechanical Specifications', :url => admin_mechanical_specifications_path}
  end

end
