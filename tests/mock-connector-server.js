const https = require('https')

const basicListener = function (req, res) {
    console.log(`Req: ${req.url}`)
    let urlPattern = /\/v1\/api\/notifications\/(?<provider>\w+)/g

    let urlMatch = urlPattern.exec(req.url)

    if (urlMatch) {
        res.writeHead(200)
        res.end(`Thank you ${urlMatch.groups.provider}`)
        return
    }

    res.writeHead(404)
    res.end('Not found')
}

const server = https.createServer(basicListener)
server.listen(process.env["HTTPS_PORT"] ?? 5001, "0.0.0.0")