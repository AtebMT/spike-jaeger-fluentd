'use strict';

const Syslogd = require('./syslog-server');
const request = require('request-promise');

Syslogd(message => {
  let json = JSON.stringify({
    text: message.msg,
    time: message.time,
    level: message.severity
  });

  let endpoint = `${message.appname}.log`;

  try {
    // If this is an event then hack the JSON sent to the endpoint
    JSON.parse(message.msg);
    endpoint = `${message.appname}.event`;
    json = message.msg;
  } catch (e) {
    // Assume its a text mesage that needs to be logged
  }

  return request({
    method: 'POST',
    uri: `http://10.0.2.15:24224/${endpoint}`,
    formData: {
      json
    }
  });
}).listen(5144, function(err) {
    console.log('starting syslogd');
    console.log('Error? ', err);
});
