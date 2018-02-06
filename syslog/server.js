'use strict';

const Syslogd = require('./syslog-server');
const request = require('request-promise');

Syslogd(message => {
  const json = JSON.stringify({
    text: message.msg,
    time: message.time,
    level: message.severity,
  });

  return request({
    method: 'POST',
    uri: `http://10.0.2.15:24224/${message.appname}.log`,
    formData: {
      json,
    },
  });
})
  .listen(5144, (err) => {
    console.log('starting syslogd');
    console.log('Error? ', err);
  });
