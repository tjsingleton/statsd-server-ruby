require "eventmachine"

module StatsD
  # Accepts StatsD Protocol messages and forwards them to a message handler
  #
  # @example A connection that prints out the messages
  #   message_inspector = ->(message) { puts message }
  #   EM.open_datagram_socket("0.0.0.0", 8125, StatsD::Connection, message_inspector)
  class Connection < EventMachine::Connection
    # @param [#call] message_handler the handler for the statsd packets
    def initialize(message_handler)
      @message_handler = message_handler
    end

    # Forwards the StatsD protocol message to the message_handler
    #
    # @param [String] message the message in the statsd protocol
    def receive_data(message)
      @message_handler.call(message)
    end
  end
end
