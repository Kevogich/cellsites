module FlashHelper
  def show_flash_messages
    f_names = [:notice, :warning, :message, :error]
    fl = ''

    for name in f_names
      if flash[name]
        fl = fl + content_tag(:div, flash[name], :class => name.to_s )
      end
      flash[name] = nil;
    end
    return fl
  end

  def show_flash_messages_js
    f_names = [:notice, :warning, :message, :error]
    fl = ''

    for name in f_names
      if flash[name]
        fl = fl + content_tag(:div, flash[name], :class => name.to_s )
      end
      flash[name] = nil;
    end
    unless fl.blank?
      "$('#flash').html( '#{ escape_javascript(fl) }' )"
    end
  end
end
