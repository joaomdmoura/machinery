const error_alert_markup = `
<div class="alert alert-danger alert-dismissible fade show" role="alert">
  Error on the request to get more resources of this state.
  <button type="button" class="close" data-dismiss="alert" aria-label="Close">
    <span aria-hidden="true">&times;</span>
  </button>
</div>`

class API {
  constructor() { this.url = "/" }

  getResourcesForState(list, callback) {
    let xhr = new XMLHttpRequest();
    let state = list.dataset.state
    page++;

    xhr.open('GET', 'machinery/api/'+state+'/resources/'+page);
    xhr.send(null);
    xhr.onreadystatechange = function () {
      const OK = 200;
      const DONE = 4;

      if (xhr.readyState === DONE) {
        if (xhr.status === OK) {
          callback(JSON.parse(xhr.response))
        } else {
          list.parentNode.querySelector('.info').innerHTML = error_alert_markup
        }
      }
    }
  }
}

const listHolders = document.querySelectorAll('.holder');
const resourcesLists = document.querySelector('.infinite-list');
const api = new API();
let page = 1;

var loadMore = function(state_holder) {
  api.getResourcesForState(state_holder, function (elements){
    elements.forEach(function (resource) {
      friendly_module_name = "lol"
      template = `
      <li class="list-group-item resource-item" data-toggle="modal" id="modal_link_${resource.id}" data-target="#modal${resource.id}">
        ${friendly_module_name} - #${resource.id}
      </li>

      <div class="modal fade" id="moda${resource.id}" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true">
        <div class="modal-dialog" role="document">
          <div class="modal-content">
            <div class="modal-header">
              <h5 class="modal-title" id="exampleModalLabel">${friendly_module_name} - #${resource.id}" %></h5>
              <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                <span aria-hidden="true">&times;</span>
              </button>
            </div>
            <div class="modal-body">
              <table class="table table-striped">
                <tbody>
                  ${
                    "lol"
                  }
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>
      `
      resourcesLists.insertAdjacentHTML('beforeend', template);
    })
  });
}

listHolders.forEach(function(holder) {
  holder.addEventListener('scroll', function() {
    if (holder.scrollTop + holder.clientHeight >= holder.scrollHeight) {
      loadMore(holder);
    }
  });
});
