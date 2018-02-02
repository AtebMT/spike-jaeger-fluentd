require 'fluent/plugin/output'
require 'jaeger/client'

module Fluent::Plugin
  class Jaeger < Output
    Fluent::Plugin.register_output('jaeger', self)

    @@store = {}

    # helpers :thread  # for try_write

    # config_param :path, :string

    def initialize
      @client = ::OpenTracing.global_tracer = ::Jaeger::Client.build(host: 'jaeger', port: 6831, service_name: 'fluentd')
      super
    end

    def get_span(record, timestamp, tracer)
      if record.dig('action') == 'start'
        parent_id = nil
        span = nil
        if record.dig('parent_id')
          span = tracer.start_span('process', start_time: timestamp, child_of: @@store[record.dig('parent_id')])
        else
          span = tracer.start_span('process', start_time: timestamp)
        end

        @@store[record.dig('id')] = span
        span
      end

      @@store[record.dig('id')]
    end

    # method for non-buffered output mode
    def process(tag, es)
      # ::OpenTracing.global_tracer = ::Jaeger::Client.build(host: 'jaeger', port: 6831, service_name: 'fluentd')

      es.each do |time, record|
        timestamp = DateTime.iso8601(record.dig('timestamp')).to_time
        # span = OpenTracing.start_span('process', start_time: timestamp)
        span = get_span(record, timestamp, @client)

        span.set_tag('event', tag)
        # span.set_baggage_item('baggage_item', 'testing')
        span.log(timestamp: timestamp, record: record.inspect)
        # # output events to ...
        puts 'Here I am!'
        puts record.inspect
        puts time.inspect

        next unless record.dig('action') == 'finish'
        puts 'Finish span'
        span.finish(end_time: timestamp)
        @@store.delete(record.dig('id'))
      end
    end
  end
end
