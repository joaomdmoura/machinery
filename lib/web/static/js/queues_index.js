import {Socket, LongPoller} from "phoenix"

class QueuesIndex {
  static init() {
    let socket = new Socket(MOUNT_PATH + "/socket")
    socket.connect()

    let chan = socket.channel("rooms:queues", {})
    chan.join()

    $(".queue_control form").each((n, el) => {
      let form = $(el)
      form.on("submit", () => {
        $.post(form.attr("action"), form.serialize())
        return false
      });
    })

    chan.on("queue:status", msg => {
      let queue = msg["queue"],
          status = msg["status"],
          button = $(`td#queue_${queue}_control button:first`),
          form = $(button.parent()),
          row = $(`tr.queue-${queue}`)

      if (row.size() === 0) return

      row.removeClass("running pausing paused")
      row.addClass(status)

      if (status === "running") {
        form.attr("action", `/queues/${queue}/pause`)
        button.html("Pause")
        button.removeAttr("disabled")
      } else if (status === "pausing") {
        form.attr("action", "")
        button.html("Pausing...")
        button.attr("disabled", "disabled")
      } else if (status === "paused") {
        form.attr("action", `/queues/${queue}/resume`)
        button.html("Resume")
        button.removeAttr("disabled")
      }
    })
  }
}

export default QueuesIndex
