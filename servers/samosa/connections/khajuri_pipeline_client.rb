require 'socket'

module Connections
  class KhajuriPipelineClient < Messaging::Connections::GenericClient

    def initialize
      hostname = Socket.gethostname

      exchangeName = "samosa.khajuri_pipeline"
      responseRoutingKey = "samosa.khajuri_pipeline.clip_in.client.#{hostname}"
      machineRoutingKey = "samosa.khajuri_pipeline.clip_in.server.#{hostname}"

      super(exchangeName, responseRoutingKey, machineRoutingKey)
      Messaging.logger.info("Start KhajuriPipelineClient for hostname: #{hostname}")
    end

    def sendClipEvalDetails(message)
      header = Messaging::Messages::Header.dataRequest
      responseHeader, responseMessage = call(header, message)
      status = responseHeader.isDataSuccess?
      return status, responseMessage
    end
  end
end
