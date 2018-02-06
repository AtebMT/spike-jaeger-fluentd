'use strict'

const syslog = require('syslog-client')

const client = syslog.createClient('10.0.2.15', {
  port: 5144,
  transport: syslog.Transport.Udp,
  // appName: 'testing',
  rfc3164: false,
  facility: syslog.Facility.Local0,
  severity: syslog.Severity.Informational,
})

client.log('example message', {
  facility: syslog.Facility.Local7,
  severity: syslog.Severity.Alert,
  rfc3164: false,
})
