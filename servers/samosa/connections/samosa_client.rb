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

    def updateClipEval(clipEvalMessage)
      header = Messaging::Messages::Header.dataRequest
      responseHeader, responseMessage = call(header, clipEvalMessage)

      status = responseHeader.isDataSuccess?
      return status, responseMessage
    end

    def updateChiaState(iterationId, state, progress)
      header = Messaging::Messages::Header.statusRequest
      message = Messaging::Messages::Samosa::ChiaStateQuery.new(nil)
      message.iterationId = iterationId
      message.state = state
      message.progress = progress
      responseHeader, _ = call(header, message)

      responseHeader.isStatusSuccess?
    end

    def updateKhajuriState(capEvalId, state, progress)
      header = Messaging::Messages::Header.statusRequest
      message = Messaging::Messages::Samosa::KhajuriStateQuery.new(nil)
      message.capEvalId = capEvalId
      message.state = state
      message.progress = progress
      responseHeader, _ = call(header, message)

      responseHeader.isStatusSuccess?
    end

  end
end
