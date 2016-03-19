require 'socket'

module Connections
  class SamosaServer < Messaging::Connections::GenericServer

    def initialize(handler)
      hostname = Socket.gethostname

      exchangeName = "#{Messaging.config.samosa.exchange}"
      listenRoutingKey = "#{Messaging.config.samosa.routing_keys.nimki.server}.#{hostname}"

      super(exchangeName, listenRoutingKey, handler)
      Messaging.logger.info("Start SamosaServer for hostname: #{hostname}")
    end

  end
end
