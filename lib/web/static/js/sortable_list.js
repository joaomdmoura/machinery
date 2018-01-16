const alertTemplate = require('./templates/alert_template');

module.exports = class SortableList {
  constructor(holder) {
    let listElm = $(holder).find('ul.list-group')[0]
    let sortable = new Sortable(listElm, {
      group: { name: 'lists', pull: true, put: true},
      onAdd: this.changeState.bind(this)
    });
  }

  changeState(event) {
    let mountedPath = $("body")[0].dataset.mountedPath
    let itemEl = event.item;
    let resourceId = itemEl.dataset.id;
    let to_state = $(event.to).parents('.holder')[0].dataset.state;
    let url = `${mountedPath}/api/resources/${resourceId}`
    let data = {state: to_state}

    $.post(url, data, function(response) {
      if(response[0] == "error") {
        this.rollbackTransition(response[1], event);
      }
    }.bind(this)).fail(function() {
      let message = "Error on the request, check logs and try again."
      this.rollbackTransition(message, event);
    }.bind(this));
  }

  rollbackTransition(message, event) {
    let error_message = `${message} Item moved back to it's original state.`
    let template = alertTemplate.render(error_message);
    $('#alerts-holder').prepend(template);
    $('#alerts-holder ').find(".alert-danger").
    fadeTo(6000, 500).
    slideUp(500, function(){
      $('#alerts-holder ').find(".alert-danger").alert('close');
    });
    this.moveItemBack(event.item, event.from, event.oldIndex);
  }

  moveItemBack(item, state, index) {
    let _index = (index == 0) ? 0 : index - 1
    let _item = $(state).find("li.resource-item").eq(_index)
    if(_item[0]){
      if(index == 0){
        $(item).insertBefore(_item);
      }
      else {
        $(item).insertAfter(_item);
      }
    }
    else{
      $(state).prepend(item);
    }
  }
}
