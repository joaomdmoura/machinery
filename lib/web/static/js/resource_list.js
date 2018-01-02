const resourceTemplate = require('./templates/resource_template');
const ResourceLoader = require('./resource_loader.js');

const loader = new ResourceLoader();

module.exports = class ResourceList {
  constructor(list) {
    this.listHolder = list;
    this.page = 1;
  }

  loadNextPage() {
    loader.getResourcesForState(this.listHolder, this.page, function (resources){
      this.page++;
      resources.forEach(function (resource) {
        let model_name = this.listHolder.dataset.modelName
        let template = resourceTemplate.render(model_name, resource)

        $(this.listHolder).find('ul').append(template);
        $(this.listHolder).find('.resource-item:last').modal({show: false})
      }.bind(this))
    }.bind(this));
  }
}
