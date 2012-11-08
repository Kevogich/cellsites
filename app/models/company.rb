class Company < ActiveRecord::Base
  has_many :company_users
  has_many :users, :through => :company_users
  has_many :groups
  has_many :titles
  has_many :units
  has_many :clients
  has_many :projects
  has_many :process_units, :through => :projects
  has_many :measure_units
  has_many :measurements #TODO need to delete association
  has_many :sizing_criteria_categories
  has_many :sizing_criterias, :through => :sizing_criteria_categories
  has_many :line_sizings, :dependent => :destroy
  has_many :heat_and_material_balances, :through => :projects
  has_many :vessel_sizings, :dependent => :destroy
  has_many :project_pipes, :through => :projects
  has_many :unit_of_measurements, :through => :projects
  has_many :pump_sizings, :dependent => :destroy
  has_many :compressor_sizing_tags, :dependent => :destroy
  has_many :electric_motors, :dependent => :destroy
  has_many :steam_turbines, :dependent => :destroy
  has_many :hydraulic_turbines, :dependent => :destroy
  has_many :turbo_expanders, :dependent => :destroy
  has_many :control_valve_sizings, :dependent => :destroy
  has_many :flow_element_sizings, :dependent => :destroy
  has_many :storage_tank_sizings, :dependent => :destroy
  has_many :column_sizings, :dependent => :destroy
  has_many :heat_exchanger_sizings, :dependent => :destroy
  has_many :relief_device_sizings, :dependent => :destroy
  
  attr_accessor :admin_username, :admin_password

  after_create :create_admin!
  after_create :generate_license!

  private
  def create_admin!
    admin = User.new( :username => admin_username, :name => contact_person, :email => email, :password => admin_password, :password_confirmation => admin_password )
    admin.save( :validate => false )
    admin.roles << Role.identifier('admin').first
    company_users.create( :user_id => admin.id )
  end

  def generate_license!
    new_license = (1..4).map{ (1..6).map{ "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"[rand(36)] }.join }.join('-')
    self.update_attribute( :license, new_license )
  end

end
