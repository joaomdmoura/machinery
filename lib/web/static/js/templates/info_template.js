let renderInfo = function() {
  return `
  <div class="alert alert-warning alert-dismissible fade show" role="alert">
    All resources were loaded.
    <button type="button" class="close" data-dismiss="alert" aria-label="Close">
      <span aria-hidden="true">&times;</span>
    </button>
  </div>`
}

module.exports = {
  render: renderInfo
}
