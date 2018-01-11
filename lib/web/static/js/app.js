const ResourceList = require('./resource_list.js');
const SortableList = require('./sortable_list.js');
const listHolders = $('.holder');
const lists = {};

var el = $('.itemslol');


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
