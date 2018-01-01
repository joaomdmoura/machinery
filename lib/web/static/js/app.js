const ResourceList = require('./resource_list.js');
const listHolders = $('.holder');
const lists = {};

$.each(listHolders, function(_i, holder) {
  let list = new ResourceList(holder);
  let state = holder.dataset.state;
  lists[state] = list;

  $(holder).find('.load-more-btn').on('click', function(event) {
    let requestedState = holder.dataset.state;
    lists[requestedState].loadNextPage();
  })
});
