import { Controller } from "@hotwired/stimulus"

export default class AreaTags extends Controller {
  removeTag({ params }) {
    const area_id = params.area
    document.getElementById("area_tag_" + area_id).remove();
    document.getElementById("user_area_ids_" + area_id).remove();
  }

  initialize(){
    document.addEventListener("autocomplete.change", (event) => {
      const new_hidden_field_id = "user_area_ids_" + event.detail.value
      const new_hidden_field = "<input type='hidden' name='user[area_ids][]' id='user_area_ids_" + event.detail.value + "' value='" + event.detail.value + "' autocomplete='off'>"

      const new_area_tag_id = "area_tag_" + event.detail.value
      const new_area_tag = "<span id='" + new_area_tag_id + "' class='tag'>" +
                        "<span aria-hidden='true' class='close-tag' aria-label='Remove area' data-area-tags-area-param='" +
                        event.detail.value + "' data-action='click->area-tags#removeTag'>&times;</span> " +
                        event.detail.textValue + "</span>"

      document.getElementById("area_search").value= "";

      var hidden_field = document.getElementById(new_hidden_field_id)
      var area_tag = document.getElementById(new_area_tag_id)

      if (!hidden_field) {
        document.getElementById("user_area_hidden_fields").innerHTML += new_hidden_field
      }

      if (!area_tag){
        document.getElementById("area_tags").innerHTML += new_area_tag
      }

      event.stopPropagation();
    })
  }



}
