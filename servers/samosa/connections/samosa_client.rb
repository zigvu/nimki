require 'socket'

module Connections
  class SamosaClient < Messaging::Connections::GenericClient

    def initialize
      hostname = Socket.gethostname

      exchangeName = "#{Messaging.config.samosa.exchange}"
      responseRoutingKey = "#{Messaging.config.samosa.routing_keys.nimki.client}.#{hostname}"
      machineRoutingKey = "#{Messaging.config.samosa.routing_keys.rasbari.server}"

      super(exchangeName, responseRoutingKey, machineRoutingKey)
      Messaging.logger.info("Start SamosaClient for hostname: #{hostname}")
    end

    def getClipDetails(clipId)
      header = Messaging::Messages::Header.dataRequest
      message = Messaging::Messages::Samosa::ClipDetails.new(nil)
      message.clipId = clipId
      responseHeader, responseMessage = call(header, message)

      status = responseHeader.isDataSuccess?
      return status, responseMessage
    end

    def getChiaDetails(iterationId, modelBuildPath)
      header = Messaging::Messages::Header.dataRequest
      message = Messaging::Messages::Samosa::ChiaDetails.new(nil)
      message.iterationId = iterationId
      message.modelBuildPath = modelBuildPath
      responseHeader, responseMessage = call(header, message)

      status = responseHeader.isDataSuccess?
      return status, responseMessage
    end

  end
end
