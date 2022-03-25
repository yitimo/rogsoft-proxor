const http = require('http')
const fs = require('fs')
const path = require('path')
const execSync = require('child_process').execSync

const server = http.createServer((req, res) => {
  res.setHeader('content-type', 'text/plain')
  handle(req, res)
  res.statusCode = 200
  res.end()
})

console.info('listening at 80')
server.listen(80, '0.0.0.0')

function handle(req, res) {
  if (req.method === 'GET') {
    if (req.url.startsWith('/run')) {
      const queryIndex = req.url.indexOf('?')
      res.write(doCmd(req.url.substring(5, queryIndex > 0 ? queryIndex : undefined)))
      return
    }
  }
  res.write('Hello~')
}

function doCmd(cmd) {
  // if (!fs.existsSync(`/bin/${cmd}.sh`)) {
  //   return `Shell(${cmd}.sh) not found.`
  // }
  let result = ''
  try {
    result = '[success]\n' + execSync(`/bin/${cmd}.sh`).toString()
  } catch (e) {
    result = '[failed]\n' + e.toString()
  }
  return result
}
