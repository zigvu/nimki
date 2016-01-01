require 'socket'

module Connections
  class NimkiServer < Messaging::Connections::GenericServer

    def initialize(handler)
      hostname = Socket.gethostname

      exchangeName = "#{Messaging.config.video_capture.exchange}"
      listenRoutingKey = "#{Messaging.config.video_capture.routing_keys.nimki.server}.#{hostname}"

      super(exchangeName, listenRoutingKey, handler)
      Messaging.logger.info("Start NimkiServer for hostname: #{hostname}")
    end

  end
end
