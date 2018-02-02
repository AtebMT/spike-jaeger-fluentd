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
