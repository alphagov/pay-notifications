// This is a really simple script to check the notifications image runs
// correctly following a build of the Dockerfile and that it can respond
// on the /healthcheck endpoint with an HTTP 200 response.

const https = require('https')

async function testNotificationPath(path, expectedStatus = 200) {
    return new Promise((resolve, reject) => {
        const httpConfig = {
            hostname: 'notifications',
            port: 443,
            path: path,
            rejectUnauthorized: false,
            requestCert: true,
            agent: false
        }

        const notificationReq = https.request(httpConfig)

        notificationReq.on("response", response => {
            if(response.statusCode == expectedStatus) {
                resolve(`PASS: ${path} returned expected ${expectedStatus} Response`)
            } else {
                reject(`FAIL: ${path} returned status ${response.statusCode}, expected ${expectedStatus}`)
            }
        })

        notificationReq.end()

        notificationReq.on("error", error => {
            reject(error)
        })

    }).catch(error => {
        console.error(error)
    })
}

async function runTests() {
    const failedTests = []
    const testsToRun = [
        testNotificationPath('/healthcheck'),
        testNotificationPath('/request-denied', 400),
        testNotificationPath('/v1/api/notifications/worldpay'),
        testNotificationPath('/v1/api/notifications/epdq'),
        testNotificationPath('/v1/api/notifications/stripe'),
        testNotificationPath('/invalid/path', 404)
    ]

    for(const thisTest of testsToRun) {
        try {
            const thisTestResult = await thisTest
            console.log(thisTestResult)
        } catch (error) {
            console.error(error)
            failedTests.push(error)
        }
    }

    return failedTests
}

async function start() {
    const failedTests = await runTests()
    if(failedTests.length > 0) {
        console.error(`There were ${failedTests.length} failed tests`)
        console.error(failedTests)
        process.exit(1)
    }
}

start()