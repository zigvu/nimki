module Handlers
  class PingHandler
    def initialize(header, message, bufferManager)
      @header = header
      @message = message
      @bufferManager = bufferManager
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
