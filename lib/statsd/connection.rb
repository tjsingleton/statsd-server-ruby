module StatsD
  class Connection < EventMachine::Connection
    def initialize(message_handler)
      @message_handler = message_handler
    end

    def receive_data(message)
      @message_handler.call(message)
    end
  end
end
