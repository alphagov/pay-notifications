// This is a really simple script to check the notifications image runs
// correctly following a build of the Dockerfile and that it can respond
// on the /healthcheck endpoint with an HTTP 200 response.

const https = require('https')
const { exit } = require('process')

const healthcheckOptions = {
    hostname: 'notifications',
    port: 443,
    method: 'GET',
    path: '/healthcheck',
    rejectUnauthorized: false,
    requestCert: true,
    agent: false
}

async function testHealthcheck() {
    const healthcheckReq = https.request(healthcheckOptions, response => {
        console.log(`statusCode: ${response.statusCode}`)
        if (response.statusCode == "200") {
            console.log("Healthcheck OK")
            exit(0)
        }
    })

    healthcheckReq.on('error', error => {
        console.error(error)
        exit(1)
    })

    healthcheckReq.end()
}

testHealthcheck()