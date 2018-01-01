const errorTemplate = require('./templates/error_template');
const infoTemplate = require('./templates/info_template');

module.exports = class ResourceLoader {
  constructor(list) {
    this.loading = false
  }

  getResourcesForState(list, page, callback) {
    if(!this.loading){
      let state = list.dataset.state
      let nextPage = page + 1;
      let url = 'machinery/api/'+state+'/resources/'+nextPage

      let request = $.get(url, function(response) {
        callback(response)
      })
      .fail(function() {
        $(list).parent().find('.info').html(errorTemplate.render())
      });

      this.load(request, list);
    }
  }

  load(request, list){
    let loader = $(list).find('.load-more-btn')
    loader.text("Loading...");
    this.loading = true;

    request.always(function(response) {
      this.loading = false;

      if(response == ""){
        $(list).parent().find('.info').html(infoTemplate.render())
        loader.remove();
      }
      else {
        loader.text("Load More");
        loader.appendTo($(list).find('ul'));
      }
    }.bind(this));
  }
}
