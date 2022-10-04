module ApplicationHelper

  def flash_class_for(flash_level)
    case flash_level
    when 'error'
      'alert-danger'
    when 'warning'
      'alert-warning'
    when 'notice'
      'alert-primary'
    else
      'alert-primary'
    end
  end

end
