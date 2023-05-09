module SortableHelper

  def sortable(by, title=nil)
    css_class = "sortable"
    sort_direction = "desc"

    if params[:sort] == by && params[:direction].present?
      css_class += params[:direction] == "asc" ? "_asc" : "_desc"
      sort_direction = params[:direction] == "desc" ? "asc" : "desc"
    end

    link_to title, request.query_parameters.merge({ sort: by, direction: sort_direction }), { class: css_class }
  end

end
