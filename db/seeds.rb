# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

# Create Roles
if Role.count == 0
  roles = [ { :name => 'Super Admin', :identifier => 'superadmin' },
    { :name => 'Administrative', :identifier => 'admin' },
    { :name => 'Printing', :identifier => 'print' },
    { :name => 'Project Setup', :identifier => 'project_setup' },
    { :name => 'Project Execution', :identifier => 'project_execution' },
    { :name => 'All', :identifier => 'all' }
  ]
  roles.each do |role|
    Role.create( role )
  end
  puts "Roles created"
end

# Create SuperAdmin
if User.count == 0
  superadmin = User.new( :username => 'admin', :name => 'Admin', :email => 'admin@example.com', :password => 'password', :password_confirmation => 'password' )
  superadmin.save( :validate => false )
  superadmin.roles << Role.identifier('superadmin').first
  puts "Superadmin created"
end

# Create Company
if Company.count == 0
  company = Company.create( :name => 'Test Company', :admin_username => 'testadmin', :admin_password => 'password', :contact_person => 'Test Company Admin', :email => 'admin@testcompany.com' )
  puts "Company created"

  # Create Groups
  groups = [ { :name => 'Process' },
    { :name => 'Mechanical Systems' },
    { :name => 'Instrumentation' },
    { :name => 'Equipment' },
    { :name => 'Others' }
  ]
  groups.each do |group|
    company.groups.create( group )
  end
  puts "Groups created"

  # Create Titles
  titles = [ { :name => 'Project Manager' },
    { :name => 'Project Engineering' },
    { :name => 'Engineering Manager' },
    { :name => 'Discipline Manager' },
    { :name => 'Project Lead' },
    { :name => 'Engineer' },
    { :name => 'Drafting Lead' },
    { :name => 'Drafter' },
    { :name => 'Document Control' },
    { :name => 'Database & Software' },
    { :name => 'Administrator' },
    { :name => 'Administrative' },
    { :name => 'Support' }
  ]
  titles.each do |title|
    company.titles.create( title )
  end
  puts "Titles created"

  # Seed Units
  (1..20).each do |i|
    company.units.create( :name => "Process Units #{i}" )
  end
  puts "Units created"
end

# Create Pipes
if Pipe.count == 0
  pipes = [
    { :material => 'Drawn Brass', :conditions => 'new', :roughness_min => 0.01, :roughness_max => 0.0014, :roughness_recommended => 0.02 },
    { :material => 'Commercial Steel', :conditions => 'new', :roughness_min => 0.1, :roughness_max => 0.02, :roughness_recommended => 0.045 },
    { :material => 'Commercial Steel', :conditions => 'Light Rust', :roughness_min => 1.0, :roughness_max => 0.15, :roughness_recommended => 0.375 },
    { :material => 'Commercial Steel', :conditions => 'General Rust', :roughness_min => 3.0, :roughness_max => 1.0, :roughness_recommended => 2.0 },
    { :material => 'Iron', :conditions => 'Wrought, new', :roughness_min => 0.0045, :roughness_max => nil, :roughness_recommended => 0.0045 },
    { :material => 'Iron', :conditions => 'Cast, new', :roughness_min => 1.0, :roughness_max => 0.25, :roughness_recommended => 0.625 },
    { :material => 'Iron', :conditions => 'Galvanized', :roughness_min => 0.01, :roughness_max => 0.0015, :roughness_recommended => 0.15 },
    { :material => 'Iron', :conditions => 'Asphalt Coated', :roughness_min => 1.0, :roughness_max => 0.1, :roughness_recommended => 0.15 }
  ]
  pipes.each do |pipe|
    Pipe.create( pipe )
  end
  puts "Pipes Created"
end
