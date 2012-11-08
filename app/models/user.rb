class User < ActiveRecord::Base
  devise :database_authenticatable, #:registerable,
    :recoverable, :rememberable, :trackable, :validatable
  #:token_authenticatable, :confirmable, :lockable and :timeoutable

  attr_accessor :login
  attr_protected :password_salt, :encrypted_password, :reset_password_token, :remember_token

  validates_presence_of :username

  has_and_belongs_to_many :roles

  has_one :company_user
  has_one :company, :through => :company_user
  has_one :user_project_setting

  has_many :projects, :through => :project_users
  has_many :project_users

  def has_role?( role_identifier )
    return !!self.roles.find_by_identifier(role_identifier)
  end

  def role_names
    roles.map{ |r| r.name }.join(', ')
  end

  #generic method to determine the access level for a user
  def permitted_actions(params)
      actions = %w(new create edit update destroy)
	  role = self.roles.first.identifier
	  if role == "project_execution"
	  end
  end
  
  def role
	  role = self.roles.first.identifier
  end

  protected

  def self.find_for_database_authentication(conditions)
    login = conditions.delete(:login)
    where(conditions).where(["username = :value OR email = :value", { :value => login }]).first
  end

end
