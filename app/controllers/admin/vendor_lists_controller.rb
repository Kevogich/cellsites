class Admin::VendorListsController < ApplicationController
  def index
    @vendor_lists = VendorList.all

  end

  def new
    @vendor_list = VendorList.new

  end

  def create
    @vendor_list = VendorList.new(params[:vendor_list])
     @vendor_list.company_id = current_user.company.id
    if @vendor_list.save
      flash[:notice] = "Vendor has been created"
      redirect_to admin_vendor_lists_path
    else
      flash[:notice] = "Vendor can not be saved"
      render :new
    end
  end

  def edit
    @vendor_list = VendorList.find(params[:id])
    @attachments = @vendor_list.attachments
    @new_attachment = @vendor_list.attachments.new
    @comments = @vendor_list.comments
    @new_comment = @vendor_list.comments.new
  end

  def destroy
    @vendor_list = VendorList.find(params[:id])
    @vendor_list.destroy

    flash[:notice] = "Vendor has been deleted"
    respond_to do |format|
      format.js
      format.html { redirect_to admin_vendor_lists_path }
    end
  end
  def update

    @vendor_list = VendorList.find(params[:id])

    respond_to do |format|
      if @vendor_list.update_attributes(params[:vendor_list])
        format.html { redirect_to(admin_vendor_lists_path, :notice => 'Vendor list was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @vendor_list.errors, :status => :unprocessable_entity }
      end
    end
  end


end
