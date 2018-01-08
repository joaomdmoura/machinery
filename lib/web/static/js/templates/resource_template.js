let renderResource = function(model, resource) {
  return `<li class="list-group-item resource-item" data-toggle="modal" data-target="#modal${resource.id}">
    ${model} - #${resource.id}
  </li>

  <div class="modal fade" id="modal${resource.id}" tabindex="-1" role="dialog" aria-hidden="true">
    <div class="modal-dialog modal-lg" role="document">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title" id="exampleModalLabel">${model} - #${resource.id}</h5>
          <button type="button" class="close" data-dismiss="modal" aria-label="Close">
            <span aria-hidden="true">&times;</span>
          </button>
        </div>
        <div class="modal-body">
          <table class="table table-striped">
            <tbody>
              ${
                Object.keys(resource).map(key =>
                  `<tr>
                    <th scope="row">${key}</th>
                    <td>${resource[key]}</td>
                  </tr>`
                ).join('')
              }
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
  `
}

module.exports = {
  render: renderResource
}
