// This is a really simple script to check the notifications image runs
// correctly following a build of the Dockerfile and that it can respond

const https = require('https')

// This is the list of paths to test and the expected HTTP Status for each...
const testsToRun = [
    { path: '/healthcheck', expectedStatus: 200 },
    { path: '/request-denied', expectedStatus: 400 },
    { path: '/v1/api/notifications/epdq', expectedStatus: 200 },
    { path: '/v1/api/notifications/smartpay', expectedStatus: 418 },
    { path: '/v1/api/notifications/stripe', expectedStatus: 200 },
    { path: '/v1/api/notifications/worldpay', expectedStatus: 200 },
    { path: '/invalid/path', expectedStatus: 404 },
]

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
            if (response.statusCode == expectedStatus) {
                resolve(`PASS: \x1b[36m${path}\x1b[0m returned expected \x1b[36m${expectedStatus}\x1b[0m Response`)
            } else {
                reject(`FAIL: \x1b[36m${path}\x1b[0m returned status \x1b[31m${response.statusCode}\x1b[0m, expected \x1b[36m${expectedStatus}\x1b[0m`)
            }
        })

        notificationReq.end()

        notificationReq.on("error", error => {
            reject(error)
        })
    })
}

// This loops through the list of `testsToRun` above...
async function runTests() {
    const failedTests = []

    for (const thisTest of testsToRun) {
        try {
            const thisTestResult = await testNotificationPath(thisTest.path, thisTest.expectedStatus)
            console.log(thisTestResult)
        } catch (error) {
            console.error(error)
            failedTests.push(error)
        }
    }

    return failedTests
}

async function start() {
    console.log(`Starting Notification Container Tests...`)
    const failedTests = await runTests()
    if (failedTests.length > 0) {
        console.error(`There were ${failedTests.length} failed tests:`)
        console.group()
        failedTests.forEach((thisFailedTest, thisFailedTestNum) => {
            console.error(`#${thisFailedTestNum + 1}: ${thisFailedTest}`)
        })
        console.groupEnd()
        console.error('\x1b[31m%s\x1b[0m', "One or more tests failed.")
        process.exit(1)
    }
    else {
        console.log('\x1b[32m%s\x1b[0m', "All tests passed successfully.")
    }
}

start()