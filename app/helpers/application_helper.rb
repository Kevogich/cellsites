module ApplicationHelper

  def display_field( resource, field, opts = {} )
    label = opts[:label] || field.to_s.humanize
    value = opts[:value] || resource.try( field )
    content_tag( :div, content_tag( :p, label, :class => 'label' ) + content_tag( :p, value, :class => 'value' ) + content_tag( :div, '', :class => 'clear' ), :class => 'field_values' )
  end
  
  def mark_required(object, attribute)
    "*" if object.class.validators_on(attribute).map(&:class).include? ActiveModel::Validations::PresenceValidator
  end

  def new_piping_row(f)
    new_object = f.object.class.reflect_on_association(:pipings).klass.new
    new_tr = f.fields_for(:pipings, new_object, :child_index => "new_piping") do |p|
      render("piping_fields", :p => p)
    end
    content_tag :table, :class => "new_piping_tr hide" do
      new_tr
    end
  end
end
