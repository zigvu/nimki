require 'socket'

module Connections
  class KhajuriPipelineServer < Messaging::Connections::GenericServer

    def initialize(handler)
      hostname = Socket.gethostname

      exchangeName = "samosa.khajuri_pipeline"
      listenRoutingKey = "samosa.khajuri_pipeline.result_out.server.#{hostname}"

      super(exchangeName, listenRoutingKey, handler)
      Messaging.logger.info("Start KhajuriPipelineServer for hostname: #{hostname}")
    end

  end
end
