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

  def github_link(github_handle, link_text=nil)
    text = link_text || github_handle
    link_to(text, "https://github.com/" + github_handle, target: "_blank", title: "View GitHub page")
  end

end
