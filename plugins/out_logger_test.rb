require 'fluent/plugin/output'

module Fluent::Plugin
  class LoggerTest < Output
    Fluent::Plugin.register_output('logger_test', self)

    # method for non-buffered output mode
    def process(_tag, es)
      es.each do |time, record|
        puts "#{time}: #{record}"
      end
    end
  end
end
