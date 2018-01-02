let renderError = function() {
  return `
  <div class="alert alert-danger alert-dismissible fade show" role="alert">
    Error on the request to get more resources of this state.
    <button type="button" class="close" data-dismiss="alert" aria-label="Close">
      <span aria-hidden="true">&times;</span>
    </button>
  </div>`
}

module.exports = {
  render: renderError
}
