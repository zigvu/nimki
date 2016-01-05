module Handlers
  class Ping
    def initialize(header, message, captureState)
      @header = header
      @message = message
      @captureState = captureState
    end

    def handle
      # ensure that rasbari server is alive
      if @captureState.captureClient.isRemoteAlive?
        returnHeader = Messaging::Messages::Header.pingSuccess
      else
        returnHeader = Messaging::Messages::Header.pingFailure
      end
      returnMessage = Messaging::Messages::MessageFactory.getNoneMessage
      return returnHeader, returnMessage
    end

    def canHandle?
      @header.type.isPing?
    end
  end
end
