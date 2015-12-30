module Handlers
  class Ping
    def initialize(header, message, captureState)
      @header = header
      @message = message
      @captureState = captureState
    end

    def handle
      returnHeader = Messaging::Messages::Header.pingSuccess
      returnMessage = Messaging::Messages::MessageFactory.getNoneMessage
      return returnHeader, returnMessage
    end

    def canHandle?
      @header.type.isPing?
    end
  end
end
