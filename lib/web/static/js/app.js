const ResourceList = require('./resource_list.js');
const SortableList = require('./sortable_list.js');
const listHolders = $('.holder');
const lists = {};

$('#toogle-all-states').on('click', function () {
  $('div.collapse').collapse('toggle');
});

$.each(listHolders, function(_i, holder) {
  let list = new ResourceList(holder);
  let state = holder.dataset.state;
  lists[state] = list;

  new SortableList(holder)

  $(holder).find('.load-more-btn').on('click', function(event) {
    let requestedState = holder.dataset.state;
    lists[requestedState].loadNextPage();
  })
});
