# Fluentd

## Running the docker container

```
docker-compose -f dev.yml up
```
## Send an event to Fluentd

```
curl -i -X POST -d 'json={"action":"login","user":2}' http://localhost:24224/test.cycle
```

## Configuration

The fluentd configuration file can be found in `conf/fluentd.conf`. Restart the container if you modify this conf.

## Sending requests to Fluentd

Here are some sample requests. Change the datetime on the request accordingly.

* Create a span

 `curl -i -X POST http://localhost:24224/fmp.event -d 'json={"name": "mike", "colour": "purple", "timestamp": "2018-02-02T15:55:04", "id": "parent", "parent_id": null, "action": "start"}'`

* Create a span that's a child of the span just created.

 `curl -i -X POST http://localhost:24224/fmp.event -d 'json={"name": "mike", "colour": "purple", "timestamp": "2018-02-02T15:55:05", "id": "child", "parent_id": "parent", "action": "start"}'`

* Finish the child span

 `curl -i -X POST http://localhost:24224/fmp.event -d 'json={"name": "mike", "colour": "purple", "timestamp": "2018-02-02T15:55:06", "id": "child", "parent_id": "parent", "action": "finish"}'`

* Finish the parent span

 `curl -i -X POST http://localhost:24224/fmp.event -d 'json={"name": "mike", "colour": "purple", "timestamp": "2018-02-02T15:55:07", "id": "parent", "parent_id": null, "action": "finish"}'`

Navigate to Jaeger on http://localhost:16686/search and search for traces. Hopefully you should find a trace that has 2 spans, each of which have log entries.

## Sending service log output to Fluentd via Docker logger

* Startup a local copy of Flipper. (If you use a different service, edit `dev.yml` in the `logspout` service.)
* Startup the spike environment:
 ```
 docker-compose -f dev.yml up
 ```
* Hit Flipper (or whatever) service. Any stdout from the service should appear in fluentd.

All Flipper is doing is sending to stdout JSON strings like this:

```
{"spanKind": "server", "httpUrl": "http://localhost:3045/api/fmp/production?trackingId=-1&anonymous=false", "httpMethod": "GET", "timestamp": "2018-02-07T16:59:56.742Z", "action": "finish", "parent_id": nil, "id": "a3f4377f-91dc-a8b7-a41f-0530ee3070f0", "type": "trace", "process_name": "express", "duration": 6027}
```

```
{"spanKind":"client","httpUrl":"http://integration.antracks.service.consul:3333/api/data_layer/0?useCache=true","httpMethod":"GET","timestamp":"2018-02-07T16:59:56.045Z","action":"finish","parent_id":"a3f4377f-91dc-a8b7-a41f-0530ee3070f0","id":"5ec3b3e5-33a1-4957-770b-78290923b352","type":"trace","process_name":"http_request","duration":132,"statusCode":200}
```

## Some issues

* fluentd appears to silently do nothing if the JSON passed to it is invalid.

* Ruby Jaeger client does not support baggage items

* The syslog I used to get the logs from docker/logspout is flawed and needed to be changed. It's not a big deal, but we'll probably want to write our own if we use the syslog approach.
