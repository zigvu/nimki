require 'socket'

module Connections
  class StorageServer < Messaging::Connections::GenericServer

    def initialize(handler)
      hostname = Socket.gethostname

      exchangeName = "#{Messaging.config.storage.exchange}"
      listenRoutingKey = "#{Messaging.config.storage.routing_keys.nimki.server}.#{hostname}"

      super(exchangeName, listenRoutingKey, handler)
      Messaging.logger.info("Start StorageServer for hostname: #{hostname}")
    end

  end
end
