class AreasController < ApplicationController
  def search
    query = params[:q]
    @areas = Area.where("name ILIKE ?", "%" + query + "%") if query.present?
    render layout: false
  end
end


