import {Socket, LongPoller} from "phoenix"
import Rickshaw from "rickshaw"

class PageIndex {
  static init() {
    let graph = new Rickshaw.Graph({
      element: document.querySelector("#graph"),
      renderer: 'area',
      stroke: true,
      series: new Rickshaw.Series.FixedDuration([{
        name: 'finished', color: 'steelblue'
      },
      {
        name: 'failed', color: 'lightcoral'
      }], undefined, {
        timeInterval: 1000,
        maxDataPoints: 120,
        timeBase: new Date().getTime() / 1000
      })
    })

    let hoverDetail = new Rickshaw.Graph.HoverDetail( {
      graph: graph,
      xFormatter: x => {
        return new Date(x * 1000).toString()
      },
      yFormatter: y => {
        return parseInt(y)
      }
    })

    let socket = new Socket(MOUNT_PATH + "/socket")
    socket.connect()

    let chan = socket.channel("rooms:jobs", {})
    chan.join()

    chan.on("job:stats", msg => {
      graph.series.addData(msg)
      graph.render()
    })
  }
}

export default PageIndex
